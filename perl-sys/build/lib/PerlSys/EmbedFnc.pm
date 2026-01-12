package PerlSys::EmbedFnc;
use strict;
use warnings;
use autodie;

use Config::Perl::V;
use Exporter "import";
use File::Spec::Functions qw/catfile/;
use FindBin qw/$Bin/;
use PerlSys::IO qw/read_file strip/;
use PerlSys::Version qw/current_apiver/;

our @EXPORT_OK = qw/
    parse_argument
    read_embed_fnc
/;

our %EXPORT_TAGS = (all => \@EXPORT_OK);

use constant {
    EMBED_FNC_PATH => "$Bin/embed.fnc",

    BLACKLIST => {
        "sv_nolocking" => "listed as part of public api, but not actually defined",
        "sv_nounlocking" => "listed as part of public api, but does nothing",
        "sv_nosharing" => "listed as part of the public api, but does nothing",
        "op_class" => "return type OPclass is not yet supported",
        # Memory allocation functions have different signatures in newer Perls
        "malloc" => "signature differs between Perl versions",
        "calloc" => "signature differs between Perl versions",
        "realloc" => "signature differs between Perl versions",
        "mfree" => "signature differs between Perl versions",
        "safesysmalloc" => "signature differs between Perl versions",
        "safesyscalloc" => "signature differs between Perl versions",
        "safesysrealloc" => "signature differs between Perl versions",
        "safesysfree" => "signature differs between Perl versions",
        # Embedding functions have parameter name conflicts with pTHX
        "perl_run" => "parameter name conflict with pTHX my_perl",
        "perl_parse" => "parameter name conflict with pTHX my_perl",
        "perl_construct" => "parameter name conflict with pTHX my_perl",
        "perl_destruct" => "parameter name conflict with pTHX my_perl",
        "perl_alloc" => "embedding function not needed for XS",
        "perl_free" => "embedding function not needed for XS",
        "perl_clone" => "parameter name conflict with pTHX",
    },
};

sub parse_argument {
    my ($arg) = @_;

    if ($arg eq "...") {
        return [ "..." ];
    }

    my ($type, $name) = $arg =~ /(.*)\b(\w+)/ or die "unparsable argument '$arg'";

    $type = strip($type);
    $name = strip($name);

    $name =~ s/^/a_/ if $name =~ /^(?:type|fn|unsafe|let|loop|ref)$/;

    return [ $type, $name ];
}


sub find_embed_fnc {
    my $wanted = current_apiver();
    my $embed_path = catfile(EMBED_FNC_PATH, $wanted);

    if (-f $embed_path) {
        return $embed_path;
    }

    # Fall back to the closest available version
    opendir(my $dh, EMBED_FNC_PATH) or die "Cannot open embed.fnc directory: $!";
    my @versions = sort {
        # Parse version strings and compare
        my @a = ($a =~ /v(\d+)\.(\d+)(?:\.(\d+))?/);
        my @b = ($b =~ /v(\d+)\.(\d+)(?:\.(\d+))?/);
        $a[2] //= 0; $b[2] //= 0;
        ($a[0] <=> $b[0]) || ($a[1] <=> $b[1]) || ($a[2] <=> $b[2])
    } grep { /^v\d+\.\d+/ } readdir($dh);
    closedir($dh);

    # Get the latest available version
    my $latest = $versions[-1];
    warn "embed.fnc for $wanted not found, using $latest instead\n";
    return catfile(EMBED_FNC_PATH, $latest);
}

sub read_embed_fnc {
    my $embed_path = find_embed_fnc();
    my $opts = Config::Perl::V::myconfig()->{options};
    my @lines = read_file($embed_path);
    my @scope = (1);
    my @spec;
    while (defined ($_ = shift @lines)) {
        while (@lines && s/\\$/shift @lines/e) {}

        next if !$_ || /^:/;

        s/#\s*ifdef\s+(\w+)/#if defined($1)/;
        s/#\s*ifndef\s+(\w+)/#if !defined($1)/;

        if (my ($pp, $args) = /^#\s*(\w+)(.*)/) {
            if ($pp eq "if") {
                $args =~ s/defined\s*\([\w+]\)/\$opts->{$1}/;
                unshift @scope, eval $args && $scope[0];
            }
            elsif ($pp eq "endif") {
                die "unmatched #endif" if @scope < 2;
                shift @scope;
            }
            elsif ($pp eq "else") {
                $scope[0] = !$scope[0];
            }
            else {
                die "unknown directive $pp";
            }
            next;
        }

        next unless $scope[0];

        my ($flags, $type, $name, @args) = split /\s*\|\s*/;

        ($type, @args) = map s/^\s+//r =~ s/\s+$//r, ($type, @args);

        # perl volatile and nullability markers mean nothing here
        ($type, @args) = map s/\b(?:VOL|NN|NULLOK)\b\s*//gr, ($type, @args);

        @args = map parse_argument($_), @args;

        if (my $reason = BLACKLIST->{$name}) {
            warn "skipping blacklisted '$name': $reason\n";
            next;
        }

        next unless
            # public
            $flags =~ /A/ &&
            # documented
            $flags =~ /d/ &&
            # not a macro without c function
            !($flags =~ /m/ && $flags !~ /b/) &&
            # Allow functions with 'M' if they have 'b' (binary compat)
            # M flag means macro wrapper exists, but b means actual function exists
            !($flags =~ /M/ && $flags !~ /b/) &&
            # not deprecated
            $flags !~ /D/;

        # va_list is useless in rust anyway
        next if grep $_->[0] =~ /\bva_list\b/, @args;

        my $link_name = $flags =~ /[pb]/ ? "Perl_$name" : $name;

        my $call_name = $name;
        my $take_pthx = $flags !~ /n/;
        my $pass_pthx;

        # If function has Perl_$name implementation, but no friendly $name macro.
        if ($flags =~ /p/ && $flags =~ /o/ && $flags !~ /m/) {
            $call_name = "Perl_$name";
            $pass_pthx = $take_pthx;
        }


        push @spec, {
            type => $type,
            name => $name,
            args => \@args,

            link_name => $link_name,
            call_name => $call_name,

            take_pthx => $take_pthx,
            pass_pthx => $pass_pthx,
        };
    }

    return @spec;
}

1;
