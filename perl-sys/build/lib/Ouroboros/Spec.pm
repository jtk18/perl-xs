package Ouroboros::Spec;
use strict;
use warnings;

our $VERSION = "0.14";

# This stub provides the Ouroboros API specification needed by perl-sys regen.pl
# The SPEC hash contains function specs, enum specs, and constant specs

our %SPEC = (
    # Function specifications for stack and SV operations
    fn => [
        # Stack management
        { name => "ouroboros_stack_init", type => "void", params => ["ouroboros_stack_t*"], tags => {} },
        { name => "ouroboros_stack_items", type => "int", params => ["ouroboros_stack_t*"], tags => {} },
        { name => "ouroboros_stack_putback", type => "void", params => ["ouroboros_stack_t*"], tags => {} },
        { name => "ouroboros_stack_fetch", type => "SV*", params => ["ouroboros_stack_t*", "SSize_t"], tags => {} },
        { name => "ouroboros_stack_store", type => "void", params => ["ouroboros_stack_t*", "SSize_t", "SV*"], tags => {} },
        { name => "ouroboros_stack_extend", type => "void", params => ["ouroboros_stack_t*", "SSize_t"], tags => {} },
        { name => "ouroboros_stack_pushmark", type => "void", params => ["ouroboros_stack_t*"], tags => {} },
        { name => "ouroboros_stack_spagain", type => "void", params => ["ouroboros_stack_t*"], tags => {} },

        # Stack push operations - XPush variants
        { name => "ouroboros_stack_xpush_sv", type => "void", params => ["ouroboros_stack_t*", "SV*"], tags => {} },
        { name => "ouroboros_stack_xpush_sv_mortal", type => "void", params => ["ouroboros_stack_t*", "SV*"], tags => {} },
        { name => "ouroboros_stack_xpush_iv", type => "void", params => ["ouroboros_stack_t*", "IV"], tags => {} },
        { name => "ouroboros_stack_xpush_uv", type => "void", params => ["ouroboros_stack_t*", "UV"], tags => {} },
        { name => "ouroboros_stack_xpush_nv", type => "void", params => ["ouroboros_stack_t*", "NV"], tags => {} },
        { name => "ouroboros_stack_xpush_pv", type => "void", params => ["ouroboros_stack_t*", "const char*", "STRLEN"], tags => {} },
        { name => "ouroboros_stack_xpush_mortal", type => "void", params => ["ouroboros_stack_t*"], tags => {} },

        # Stack push operations - Push variants
        { name => "ouroboros_stack_push_sv", type => "void", params => ["ouroboros_stack_t*", "SV*"], tags => {} },
        { name => "ouroboros_stack_push_sv_mortal", type => "void", params => ["ouroboros_stack_t*", "SV*"], tags => {} },
        { name => "ouroboros_stack_push_iv", type => "void", params => ["ouroboros_stack_t*", "IV"], tags => {} },
        { name => "ouroboros_stack_push_uv", type => "void", params => ["ouroboros_stack_t*", "UV"], tags => {} },
        { name => "ouroboros_stack_push_nv", type => "void", params => ["ouroboros_stack_t*", "NV"], tags => {} },
        { name => "ouroboros_stack_push_pv", type => "void", params => ["ouroboros_stack_t*", "const char*", "STRLEN"], tags => {} },
        { name => "ouroboros_stack_push_mortal", type => "void", params => ["ouroboros_stack_t*"], tags => {} },

        # SV accessors - boolean checks
        { name => "ouroboros_sv_ok", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_iok", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_uok", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_nok", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_pok", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_rok", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_niok", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_true", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_utf8", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_tainted", type => "c_bool", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_is_cow", type => "c_bool", params => ["SV*"], tags => {} },

        # SV value getters
        { name => "ouroboros_sv_iv", type => "IV", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_uv", type => "UV", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_nv", type => "NV", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_pv", type => "char*", params => ["SV*", "STRLEN*"], tags => {} },
        { name => "ouroboros_sv_rv", type => "SV*", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_type", type => "svtype", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_flags", type => "UV", params => ["SV*"], tags => {} },

        # SV value setters
        { name => "ouroboros_sv_iv_set", type => "void", params => ["SV*", "IV"], tags => {} },
        { name => "ouroboros_sv_uv_set", type => "void", params => ["SV*", "UV"], tags => {} },
        { name => "ouroboros_sv_nv_set", type => "void", params => ["SV*", "NV"], tags => {} },
        { name => "ouroboros_sv_rv_set", type => "void", params => ["SV*", "SV*"], tags => {} },

        # SV string operations
        { name => "ouroboros_sv_pv_cur", type => "STRLEN", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_pv_len", type => "STRLEN", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_pv_end", type => "char*", params => ["SV*"], tags => {} },

        # Reference counting
        { name => "ouroboros_sv_refcnt", type => "U32", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_refcnt_inc", type => "SV*", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_refcnt_inc_void_nn", type => "void", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_refcnt_dec", type => "void", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_refcnt_dec_nn", type => "void", params => ["SV*"], tags => {} },

        # Magic
        { name => "ouroboros_sv_get_magic", type => "void", params => ["SV*"], tags => {} },
        { name => "ouroboros_sv_set_magic", type => "void", params => ["SV*"], tags => {} },

        # GV accessors
        { name => "ouroboros_gv_sv", type => "SV*", params => ["GV*"], tags => {} },
        { name => "ouroboros_gv_av", type => "AV*", params => ["GV*"], tags => {} },
        { name => "ouroboros_gv_hv", type => "HV*", params => ["GV*"], tags => {} },
        { name => "ouroboros_gv_cv", type => "CV*", params => ["GV*"], tags => {} },

        # HV name functions
        { name => "ouroboros_hv_name", type => "const char*", params => ["HV*"], tags => {} },
        { name => "ouroboros_hv_name_len", type => "STRLEN", params => ["HV*"], tags => {} },
        { name => "ouroboros_hv_name_utf8", type => "c_bool", params => ["HV*"], tags => {} },
        { name => "ouroboros_hv_ename", type => "const char*", params => ["HV*"], tags => {} },
        { name => "ouroboros_hv_ename_len", type => "STRLEN", params => ["HV*"], tags => {} },
        { name => "ouroboros_hv_ename_utf8", type => "c_bool", params => ["HV*"], tags => {} },

        # HE functions
        { name => "ouroboros_he_pv", type => "const char*", params => ["HE*", "STRLEN*"], tags => {} },
        { name => "ouroboros_he_val", type => "SV*", params => ["HE*"], tags => {} },
        { name => "ouroboros_he_hash", type => "U32", params => ["HE*"], tags => {} },
        { name => "ouroboros_he_svkey", type => "SV*", params => ["HE*"], tags => {} },

        # Hash function
        { name => "ouroboros_perl_hash", type => "U32", params => ["const char*", "STRLEN"], tags => {} },

        # Scope management
        { name => "ouroboros_enter", type => "void", params => [], tags => {} },
        { name => "ouroboros_leave", type => "void", params => [], tags => {} },
        { name => "ouroboros_savetmps", type => "void", params => [], tags => {} },
        { name => "ouroboros_freetmps", type => "void", params => [], tags => {} },

        # Exception handling
        { name => "ouroboros_xcpt_try", type => "int", params => ["ouroboros_xcpt_callback_t", "void*"], tags => { no_pthx => 0 } },
        { name => "ouroboros_xcpt_rethrow", type => "void", params => [], tags => {} },

        # Context
        { name => "ouroboros_gimme", type => "U8", params => [], tags => {} },

        # Global SVs
        { name => "ouroboros_sv_undef", type => "SV*", params => [], tags => {} },
        { name => "ouroboros_sv_no", type => "SV*", params => [], tags => {} },
        { name => "ouroboros_sv_yes", type => "SV*", params => [], tags => {} },

        # Perl embedding functions
        { name => "ouroboros_sys_init3", type => "void", params => ["int*", "char***", "char***"], tags => { no_pthx => 1 } },
        { name => "ouroboros_sys_term", type => "void", params => [], tags => { no_pthx => 1 } },
    ],

    # Enum definitions
    enum => [
        { name => "SVt_NULL", c_type => "U32" },
        { name => "SVt_IV", c_type => "U32" },
        { name => "SVt_NV", c_type => "U32" },
        { name => "SVt_PV", c_type => "U32" },
        { name => "SVt_PVIV", c_type => "U32" },
        { name => "SVt_PVNV", c_type => "U32" },
        { name => "SVt_PVMG", c_type => "U32" },
        { name => "SVt_REGEXP", c_type => "U32" },
        { name => "SVt_PVGV", c_type => "U32" },
        { name => "SVt_PVLV", c_type => "U32" },
        { name => "SVt_PVAV", c_type => "U32" },
        { name => "SVt_PVHV", c_type => "U32" },
        { name => "SVt_PVCV", c_type => "U32" },
        { name => "SVt_PVFM", c_type => "U32" },
        { name => "SVt_PVIO", c_type => "U32" },
        { name => "SVt_LAST", c_type => "U32" },
    ],

    # Constant definitions
    const => [
        { name => "SV_CATBYTES", c_type => "U32" },
        { name => "SV_CATUTF8", c_type => "U32" },
        { name => "SV_CONST_RETURN", c_type => "U32" },
        { name => "SV_GMAGIC", c_type => "U32" },
        { name => "SV_SMAGIC", c_type => "U32" },
        { name => "SV_NOSTEAL", c_type => "U32" },
        { name => "SV_FORCE_UTF8_UPGRADE", c_type => "U32" },
        { name => "SV_COW_DROP_PV", c_type => "U32" },
        { name => "SV_HAS_TRAILING_NUL", c_type => "U32" },
        { name => "SV_IMMEDIATE_UNREF", c_type => "U32" },
        { name => "GV_ADD", c_type => "U32" },
        { name => "GV_ADDMG", c_type => "U32" },
        { name => "GV_ADDMULTI", c_type => "U32" },
        { name => "GV_NOADD_NOINIT", c_type => "U32" },
        { name => "GV_NOEXPAND", c_type => "U32" },
        { name => "GV_NOINIT", c_type => "U32" },
        { name => "GV_SUPER", c_type => "U32" },
        { name => "PERL_MAGIC_ext", c_type => "U32" },
    ],
);

1;
__END__
