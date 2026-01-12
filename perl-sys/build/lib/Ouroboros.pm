package Ouroboros;
use strict;
use warnings;
use Config;

# This is a minimal stub implementation of Ouroboros for perl-sys build
# It provides the SIZE_OF hash and CONSTS array needed by regen.pl

our $VERSION = "0.14";

# Type sizes - computed from Perl's Config where possible
# For types not in Config, we use reasonable defaults for modern 64-bit systems
our %SIZE_OF = (
    bool              => 1,    # C99 bool or unsigned char
    svtype            => 4,    # U32 enum in modern Perl
    PADOFFSET         => $Config{sizesize},  # Same as Size_t
    Optype            => 2,    # U16 in modern Perl
    ouroboros_stack_t => 1024, # Stack buffer size (generous default)
);

# List of constants that are actually exported by Ouroboros
our @CONSTS = qw(
    SVt_NULL SVt_IV SVt_NV SVt_PV SVt_PVIV SVt_PVNV SVt_PVMG
    SVt_REGEXP SVt_PVGV SVt_PVLV SVt_PVAV SVt_PVHV SVt_PVCV
    SVt_PVFM SVt_PVIO SVt_LAST

    SV_CATBYTES SV_CATUTF8 SV_CONST_RETURN SV_GMAGIC SV_SMAGIC
    SV_NOSTEAL SV_FORCE_UTF8_UPGRADE SV_COW_DROP_PV
    SV_HAS_TRAILING_NUL SV_IMMEDIATE_UNREF

    GV_ADD GV_ADDMG GV_ADDMULTI GV_NOADD_NOINIT GV_NOEXPAND
    GV_NOINIT GV_SUPER

    PERL_MAGIC_ext
);

# Constant value subroutines - these return the actual values
# SVt_* constants are defined in Perl's sv.h

sub SVt_NULL   { 0 }
sub SVt_IV     { 1 }
sub SVt_NV     { 2 }
sub SVt_PV     { 3 }
sub SVt_PVIV   { 4 }
sub SVt_PVNV   { 5 }
sub SVt_PVMG   { 6 }
sub SVt_REGEXP { 7 }
sub SVt_PVGV   { 9 }
sub SVt_PVLV   { 10 }
sub SVt_PVAV   { 11 }
sub SVt_PVHV   { 12 }
sub SVt_PVCV   { 13 }
sub SVt_PVFM   { 14 }
sub SVt_PVIO   { 15 }
sub SVt_LAST   { 16 }

# SV flags from sv.h
sub SV_CATBYTES           { 0x00000002 }
sub SV_CATUTF8            { 0x00000004 }
sub SV_CONST_RETURN       { 0x00000020 }
sub SV_GMAGIC             { 0x00000200 }
sub SV_SMAGIC             { 0x00100000 }
sub SV_NOSTEAL            { 0x00000010 }
sub SV_FORCE_UTF8_UPGRADE { 0x00004000 }
sub SV_COW_DROP_PV        { 0x00010000 }
sub SV_HAS_TRAILING_NUL   { 0x00040000 }
sub SV_IMMEDIATE_UNREF    { 0x00008000 }

# GV flags from gv.h
sub GV_ADD           { 0x01 }
sub GV_ADDMG         { 0x02 }
sub GV_ADDMULTI      { 0x04 }
sub GV_NOADD_NOINIT  { 0x10 }
sub GV_NOEXPAND      { 0x20 }
sub GV_NOINIT        { 0x08 }
sub GV_SUPER         { 0x1000 }

# PERL_MAGIC_* constants from mg.h
sub PERL_MAGIC_ext   { ord('~') }  # '~' = 126

1;
__END__
