package PerlSys::RustSyn;
use strict;
use warnings;

use Config;
use Exporter qw/import/;

our @EXPORT_OK = qw/
    TYPEMAP
    map_type
    indent
    mod
    type
    extern
    link_name
    _fn
    fn
    extern_fn
    callback_fn
    callback_ptr
    linked_fn
    const
    struct
    cstruct
    cstruct_pub
    struct_val
    enum
    impl
    let
    rif
/;

our %EXPORT_TAGS = (all => \@EXPORT_OK);

use constant {
    TYPEMAP => {
        "ouroboros_stack_t" => "OuroborosStack",
        "ouroboros_xcpt_callback_t" => "unsafe extern \"C\" fn(*mut ::std::os::raw::c_void)",

        "void" => "::std::os::raw::c_void",
        "int" => "::std::os::raw::c_int",
        "unsigned" => "::std::os::raw::c_uint",
        "unsigned int" => "::std::os::raw::c_uint",
        "char" => "::std::os::raw::c_char",
        "unsigned char" => "::std::os::raw::c_uchar",
        "long" => "::std::os::raw::c_long",
        "unsigned long" => "::std::os::raw::c_ulong",

        "bool" => "c_bool",
        "size_t" => "Size_t",

        # Perl-specific size types
        "MEM_SIZE" => "Size_t",  # size_t alias in perl
        "PERL_CONTEXT" => "PERL_CONTEXT",  # opaque context type

        # Memory allocation types
        "Malloc_t" => "*mut ::std::os::raw::c_void",  # void* for malloc
        "Free_t" => "::std::os::raw::c_void",  # void for free

        # File and I/O types
        "FILE" => "::std::os::raw::c_void",  # opaque FILE type
        "Pid_t" => "::std::os::raw::c_int",  # process ID type
        "Off_t" => "i64",  # file offset type
        "Mode_t" => "u32",  # file mode type
        "Uid_t" => "u32",  # user ID type
        "Gid_t" => "u32",  # group ID type
        "Time_t" => "i64",  # time type
        "Signal_t" => "::std::os::raw::c_void",  # signal return type (void)
        "Sighandler_t" => "unsafe extern \"C\" fn(::std::os::raw::c_int)",  # signal handler
        "Sigjmp_buf" => "::std::os::raw::c_void",  # sigjmp_buf opaque

        # Perl string types
        "line_t" => "U32",  # line number type

        # Locale types
        "locale_t" => "*mut ::std::os::raw::c_void",  # locale_t handle

        "MAGIC" => "MAGIC",
        "MGVTBL" => "MGVTBL",

        # Perl internal opaque types
        "COP" => "::std::os::raw::c_void",  # code cop structure
        "GP" => "::std::os::raw::c_void",  # glob entry
        "PAD" => "::std::os::raw::c_void",  # pad structure
        "PERL_SI" => "::std::os::raw::c_void",  # stack info
        "XPVMG" => "::std::os::raw::c_void",  # magic PV
        "XPVAV" => "::std::os::raw::c_void",  # array PV
        "XPVHV" => "::std::os::raw::c_void",  # hash PV
        "XPVCV" => "::std::os::raw::c_void",  # code PV
        "XPVIV" => "::std::os::raw::c_void",  # IV PV
        "XPVNV" => "::std::os::raw::c_void",  # NV PV
        "XPVGV" => "::std::os::raw::c_void",  # glob PV
        "XPVIO" => "::std::os::raw::c_void",  # IO PV
        "XPVFM" => "::std::os::raw::c_void",  # format PV
        "XPVLV" => "::std::os::raw::c_void",  # lvalue PV
        "XPVBM" => "::std::os::raw::c_void",  # boyer-moore PV
        "REGEXP" => "::std::os::raw::c_void",  # compiled regex
        "regexp" => "::std::os::raw::c_void",  # compiled regex (lowercase)
        "PMOP" => "::std::os::raw::c_void",  # pattern match OP
        "UNOP" => "::std::os::raw::c_void",  # unary OP
        "BINOP" => "::std::os::raw::c_void",  # binary OP
        "LOGOP" => "::std::os::raw::c_void",  # logical OP
        "LISTOP" => "::std::os::raw::c_void",  # list OP
        "SVOP" => "::std::os::raw::c_void",  # SV OP
        "PVOP" => "::std::os::raw::c_void",  # PV OP
        "METHOP" => "::std::os::raw::c_void",  # method OP

        # More internal types
        "regmatch_info" => "::std::os::raw::c_void",
        "regmatch_slab" => "::std::os::raw::c_void",
        "reg_ac_data" => "::std::os::raw::c_void",
        "reg_trie_trans_le" => "::std::os::raw::c_void",
        "struct reg_code_block" => "::std::os::raw::c_void",
        "INVLIST" => "::std::os::raw::c_void",

        # Perl_debug types
        "PTR_TBL_ENT_t" => "::std::os::raw::c_void",
        "PTR_TBL_t" => "::std::os::raw::c_void",

        # Function pointer types
        "Perl_ppaddr_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter) -> *mut OP",
        "Perl_check_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter, *mut OP) -> *mut OP",
        "Perl_ophook_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter, *mut OP)",

        # Additional Perl types
        "STRLEN_UNDEF_OK" => "Size_t",
        "MADPROP" => "::std::os::raw::c_void",
        "yy_parser" => "::std::os::raw::c_void",
        "yy_stack_frame" => "::std::os::raw::c_void",
        "OPSLAB" => "::std::os::raw::c_void",

        # Threading types
        "perl_mutex" => "::std::os::raw::c_void",
        "perl_key" => "::std::os::raw::c_void",
        "perl_cond" => "::std::os::raw::c_void",
        "PerlIO_funcs" => "::std::os::raw::c_void",
        "PerlIO_list_t" => "::std::os::raw::c_void",

        # Interpreter types
        "PerlInterpreter" => "PerlInterpreter",
        "INTERP" => "PerlInterpreter",

        # XOP types
        "XOP" => "::std::os::raw::c_void",
        "XOPRETANY" => "::std::os::raw::c_void",

        # Parse/compile types
        "SvREFCNT_stolen" => "SV",
        "OPCODE" => "U16",
        "STRLEN" => "Size_t",
        "U_I32" => "U32",

        # Debugging types
        "debug_file" => "::std::os::raw::c_void",
        "runops_proc_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter) -> ::std::os::raw::c_int",
        "Perl_keyword_plugin_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter, *mut ::std::os::raw::c_char, STRLEN, *mut *mut OP) -> ::std::os::raw::c_int",
        "XSINIT_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter)",

        # Hash types
        "HEK" => "::std::os::raw::c_void",
        "SHARED_HEK" => "::std::os::raw::c_void",

        # More ops
        "PADOP" => "::std::os::raw::c_void",
        "BASEOP" => "::std::os::raw::c_void",
        "COPHH" => "::std::os::raw::c_void",
        "OPSLOT" => "::std::os::raw::c_void",

        # regcomp types
        "regnode" => "::std::os::raw::c_void",
        "regnode_string" => "::std::os::raw::c_void",
        "regnode_anyofhs" => "::std::os::raw::c_void",
        "RExC_state_t" => "::std::os::raw::c_void",
        "scan_data_t" => "::std::os::raw::c_void",
        "ScanDataFlags_t" => "U32",

        # Filter types
        "filter_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter, ::std::os::raw::c_int, *mut SV, ::std::os::raw::c_int) -> I32",

        # More Perl types
        "NV_U" => "NV",
        "UOFF_T" => "UV",
        "token" => "::std::os::raw::c_void",
        "TOKEN" => "::std::os::raw::c_void",
        "YYSTYPE" => "::std::os::raw::c_void",
        "PL_local_patches" => "*mut *mut ::std::os::raw::c_char",
        "PL_patchlevel" => "*mut SV",

        # Locale categories
        "locale_category_index" => "::std::os::raw::c_int",
        "save_to_buffer" => "::std::os::raw::c_void",

        # cv flags
        "cv_flags_t" => "U32",

        # utf8 types
        "utf8_and_requests" => "U32",

        # wrap types
        "reg_extflags_name" => "::std::os::raw::c_void",

        # Core types that might be missing
        "PL_collation_name" => "*mut ::std::os::raw::c_char",
        "PL_numeric_name" => "*mut ::std::os::raw::c_char",

        # Special variables and state
        "GT_CONST" => "U32",
        "HASH_SEED_KEY" => "*mut U8",

        # C standard library types
        "struct tm" => "::std::os::raw::c_void",  # time struct
        "struct stat" => "::std::os::raw::c_void",  # file stat
        "struct utimbuf" => "::std::os::raw::c_void",  # utime buffer
        "DIR" => "::std::os::raw::c_void",  # directory stream
        "struct dirent" => "::std::os::raw::c_void",  # directory entry

        # Short forms
        "tm" => "::std::os::raw::c_void",

        # Perl MRO types
        "struct mro_meta" => "::std::os::raw::c_void",
        "mro_meta" => "::std::os::raw::c_void",
        "struct mro_alg" => "::std::os::raw::c_void",
        "mro_alg" => "::std::os::raw::c_void",

        # Additional internal types
        "LOGOP" => "::std::os::raw::c_void",
        "LOOP" => "::std::os::raw::c_void",
        "PMOP" => "::std::os::raw::c_void",
        "COP" => "::std::os::raw::c_void",

        # Perl GV types
        "GV" => "GV",
        "HV" => "HV",
        "AV" => "AV",
        "CV" => "CV",
        "SV" => "SV",
        "OP" => "OP",
        "IO" => "IO",
        "HE" => "HE",
        "PADLIST" => "PADLIST",
        "PADNAME" => "PADNAME",
        "PADNAMELIST" => "PADNAMELIST",
        "BHK" => "BHK",
        "CLONE_PARAMS" => "CLONE_PARAMS",
        "PerlIO" => "PerlIO",
        "UNOP_AUX_item" => "UNOP_AUX_item",

        # Pad types
        "padtidy_type" => "::std::os::raw::c_int",

        # Scope types
        "save_type_t" => "U8",

        # Locale types extended
        "yy_state_t" => "::std::os::raw::c_int",
        "YYLTYPE" => "::std::os::raw::c_void",
        "Perl_sv_flags_t" => "U32",

        # utf8 types extended
        "utf8n_flags_t" => "U32",

        # Sort types
        "SVCOMPARE_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter, *mut SV, *mut SV) -> I32",

        # GV additional
        "gv_fetchmethod_flags_t" => "U32",

        # Additional Perl internals
        "BUF_PAT_DEPTH_T" => "U32",
        "Line_t" => "U32",
        "Perl_cpeep_t" => "unsafe extern \"C\" fn(*mut PerlInterpreter, *mut OP, *mut OP)",
        "Perl_call_checker" => "unsafe extern \"C\" fn(*mut PerlInterpreter, *mut OP, *mut GV, *mut SV) -> *mut OP",
    },
};

sub map_type {
    my ($type) = @_;

    # working copy
    my $work = $type;
    my $mode = "mut";
    my @base_type;
    my @ptr;

    my $lim = 100;
    while ($work && --$lim > 0) {
        if ($work =~ s/^const\s*//) {
            $mode = "const";
        }
        elsif ($work =~ s/^volatile\s*//) {
        }
        elsif ($work =~ s/^(\w+)\s*//) {
            push @base_type, $1;
        }
        elsif ($work =~ s/^\*\s*//) {
            unshift @ptr, $mode;
            $mode = "mut";
        }
        else {
            die "can't parse $work (was: $type)";
        }
    }

    die "unparsable type '$type'" if !$lim;

    my $base_type = join " ", @base_type;
    my $rust_type = TYPEMAP->{$base_type}
        or die "unknown type $base_type (was: $type)";

    return join " ", map("*$_", @ptr), $rust_type;
}


sub indent {
    map "    $_", @_;
}

sub mod {
    my ($name, @items) = @_;
    return (
        "pub mod $name {",
        indent(@items),
        "}",
    );
}

sub type {
    my ($name, $ty) = @_;

    TYPEMAP->{$name} = $name;

    return "pub type $name = $ty;";
}

sub extern {
    my ($abi, @items) = @_;
    # Rust 2024 requires unsafe on extern blocks
    return (
        "unsafe extern \"$abi\" {",
        indent(@items),
        "}",
    );
}

sub link_name {
    my ($name) = @_;
    return (qq!#[link_name="$name"]!);
}

sub _fn {
    my ($qual, $fn) = @_;

    my @formal;

    push @formal, $fn->{take_self} if $fn->{take_self};
    push @formal, "my_perl: *mut PerlInterpreter" if $fn->{take_pthx} && $Config{usemultiplicity};

    foreach my $arg (@{$fn->{args}}) {
        my ($type, $name) = @$arg;
        if ($type eq "...") {
            push @formal, "...";
        }
        else {
            my $rs_type = map_type($type);
            push @formal, $name ? "$name: $rs_type" : $rs_type;
        }
    }

    my $returns = $fn->{type} eq "void" ? "" : " -> " . map_type($fn->{type});

    local $" = ", ";

    return "$qual fn $fn->{name}(@formal)$returns";
}

sub fn {
    return _fn("pub", @_) . ";";
}

sub extern_fn {
    my ($type, @args) = @_;

    # Rust 2024 requires unsafe on extern fn types
    return _fn('unsafe extern "C"', {
        type => $type,
        name => "",
        args => [ map [ $_ ], @args ],
        take_pthx => 1,
    });
}

sub callback_fn {
    my ($type, $pthx, @args) = @_;

    # Rust 2024 requires unsafe on extern fn types
    return _fn('unsafe extern "C"', {
        type => $type,
        name => "",
        args => \@args,
        take_pthx => $pthx,
    });
}

sub callback_ptr {
    my ($type, $pthx, @args) = @_;
    return sprintf "Option<%s>", callback_fn($type, $pthx, @args);
}

sub linked_fn {
    my ($fn) = @_;

    return (
        link_name($fn->{link_name}),
        fn($fn),
    );
}

sub const {
    my ($name, $type, $head, @rest) = @_;

    my @lines = (
        "pub const $name: $type = $head",
        @rest,
    );

    $lines[-1] .= ";";

    return @lines;
}

sub struct {
    my ($name, @fields) = @_;

    TYPEMAP->{$name} = $name;

    my @fields_rs;
    while (my ($name, $type) = splice @fields, 0, 2) {
        push @fields_rs, sprintf "%s: %s,", $name, $type;
    }

    return (
        "pub struct $name {",
        indent(@fields_rs),
        "}"
    );
}

sub cstruct {
    my ($name, @fields) = @_;
    return (
        "#[repr(C)]",
        struct($name, @fields),
    );
}

sub cstruct_pub {
    my ($name, @fields) = @_;

    my @pub_fields;
    while (my ($name, $type) = splice @fields, 0, 2) {
        push @pub_fields, "pub $name" => $type;
    }

    return cstruct($name, @pub_fields);
}

sub struct_val {
    my ($type, @fields) = @_;

    my @init;
    while (my ($name, $value) = splice @fields, 0, 2) {
        push @init, "$name: $value,";
    }

    return "$type {", indent(@init), "}";
}

sub enum {
    my ($name, @items) = @_;
    die "non-empty enums are not supported yet" if @items;

    TYPEMAP->{$name} = $name;

    return "pub enum $name {}";
}

sub impl {
    my ($name, @lines) = @_;
    return (
        "impl $name {",
        indent(@lines),
        "}"
    );
}

sub let {
    my ($name, $type, $init) = @_;

    return "let $name"
        . ($type ? ": $type" : "")
        . ($init ? " = $init" : "")
        . ";";
}

sub rif {
    my ($cond, $then, $else) = @_;

    return (
        "if $cond {",
        indent(@$then),
        "}",
        $else ? ("{", indent(@$else), "}") : (),
    );
}

1;
