package Ouroboros::Library;
use strict;
use warnings;
use File::Spec::Functions qw/catfile/;
use FindBin '$Bin';

our $VERSION = "0.14";

# Return paths to libouroboros header files
sub c_header {
    return catfile($Bin, "lib", "libouroboros", "libouroboros.h");
}

# Return paths to libouroboros source files
sub c_source {
    return catfile($Bin, "lib", "libouroboros", "libouroboros.c");
}

1;
__END__
