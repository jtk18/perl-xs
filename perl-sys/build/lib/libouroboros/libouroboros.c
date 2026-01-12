/*
 * libouroboros.c - Minimal Ouroboros implementation for perl-sys
 *
 * Provides XS macro wrappers as C functions.
 */

/* Stack management */

void ouroboros_stack_init(pTHX_ ouroboros_stack_t* stack) {
    dSP;
    dMARK;
    dAX;
    dITEMS;
    stack->sp = SP;
    stack->ax = ax;
    stack->items = items;
    stack->mark = TOPMARK;
}

int ouroboros_stack_items(pTHX_ ouroboros_stack_t* stack) {
    return stack->items;
}

void ouroboros_stack_putback(pTHX_ ouroboros_stack_t* stack) {
    /* PUTBACK expands to PL_stack_sp = sp, so we need local sp */
    SV** sp = stack->sp;
    PUTBACK;
}

SV* ouroboros_stack_fetch(pTHX_ ouroboros_stack_t* stack, SSize_t idx) {
    /* ST(off) expands to PL_stack_base[ax + (off)] */
    return PL_stack_base[stack->ax + idx];
}

void ouroboros_stack_store(pTHX_ ouroboros_stack_t* stack, SSize_t idx, SV* sv) {
    /* ST(off) expands to PL_stack_base[ax + (off)] */
    PL_stack_base[stack->ax + idx] = sv;
}

void ouroboros_stack_extend(pTHX_ ouroboros_stack_t* stack, SSize_t n) {
    SV** sp = stack->sp;
    EXTEND(sp, n);
    stack->sp = sp;
}

void ouroboros_stack_pushmark(pTHX_ ouroboros_stack_t* stack) {
    PUSHMARK(stack->sp);
}

void ouroboros_stack_spagain(pTHX_ ouroboros_stack_t* stack) {
    dSP;
    stack->sp = SP;
}

/* XPush variants */

void ouroboros_stack_xpush_sv(pTHX_ ouroboros_stack_t* stack, SV* sv) {
    SV** sp = stack->sp;
    XPUSHs(sv);
    stack->sp = sp;
}

void ouroboros_stack_xpush_sv_mortal(pTHX_ ouroboros_stack_t* stack, SV* sv) {
    SV** sp = stack->sp;
    mXPUSHs(sv);
    stack->sp = sp;
}

void ouroboros_stack_xpush_iv(pTHX_ ouroboros_stack_t* stack, IV iv) {
    SV** sp = stack->sp;
    mXPUSHi(iv);
    stack->sp = sp;
}

void ouroboros_stack_xpush_uv(pTHX_ ouroboros_stack_t* stack, UV uv) {
    SV** sp = stack->sp;
    mXPUSHu(uv);
    stack->sp = sp;
}

void ouroboros_stack_xpush_nv(pTHX_ ouroboros_stack_t* stack, NV nv) {
    SV** sp = stack->sp;
    mXPUSHn(nv);
    stack->sp = sp;
}

void ouroboros_stack_xpush_pv(pTHX_ ouroboros_stack_t* stack, const char* pv, STRLEN len) {
    SV** sp = stack->sp;
    mXPUSHp(pv, len);
    stack->sp = sp;
}

void ouroboros_stack_xpush_mortal(pTHX_ ouroboros_stack_t* stack) {
    SV** sp = stack->sp;
    XPUSHs(sv_newmortal());
    stack->sp = sp;
}

/* Push variants */

void ouroboros_stack_push_sv(pTHX_ ouroboros_stack_t* stack, SV* sv) {
    SV** sp = stack->sp;
    PUSHs(sv);
    stack->sp = sp;
}

void ouroboros_stack_push_sv_mortal(pTHX_ ouroboros_stack_t* stack, SV* sv) {
    SV** sp = stack->sp;
    mPUSHs(sv);
    stack->sp = sp;
}

void ouroboros_stack_push_iv(pTHX_ ouroboros_stack_t* stack, IV iv) {
    SV** sp = stack->sp;
    mPUSHi(iv);
    stack->sp = sp;
}

void ouroboros_stack_push_uv(pTHX_ ouroboros_stack_t* stack, UV uv) {
    SV** sp = stack->sp;
    mPUSHu(uv);
    stack->sp = sp;
}

void ouroboros_stack_push_nv(pTHX_ ouroboros_stack_t* stack, NV nv) {
    SV** sp = stack->sp;
    mPUSHn(nv);
    stack->sp = sp;
}

void ouroboros_stack_push_pv(pTHX_ ouroboros_stack_t* stack, const char* pv, STRLEN len) {
    SV** sp = stack->sp;
    mPUSHp(pv, len);
    stack->sp = sp;
}

void ouroboros_stack_push_mortal(pTHX_ ouroboros_stack_t* stack) {
    SV** sp = stack->sp;
    PUSHs(sv_newmortal());
    stack->sp = sp;
}

/* SV type checks */

unsigned char ouroboros_sv_ok(pTHX_ SV* sv) {
    return SvOK(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_iok(pTHX_ SV* sv) {
    return SvIOK(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_uok(pTHX_ SV* sv) {
    return SvUOK(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_nok(pTHX_ SV* sv) {
    return SvNOK(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_pok(pTHX_ SV* sv) {
    return SvPOK(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_rok(pTHX_ SV* sv) {
    return SvROK(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_niok(pTHX_ SV* sv) {
    return SvNIOK(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_true(pTHX_ SV* sv) {
    return SvTRUE(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_utf8(pTHX_ SV* sv) {
    return SvUTF8(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_tainted(pTHX_ SV* sv) {
    return SvTAINTED(sv) ? 1 : 0;
}

unsigned char ouroboros_sv_is_cow(pTHX_ SV* sv) {
    return SvIsCOW(sv) ? 1 : 0;
}

/* SV value getters */

IV ouroboros_sv_iv(pTHX_ SV* sv) {
    return SvIV(sv);
}

UV ouroboros_sv_uv(pTHX_ SV* sv) {
    return SvUV(sv);
}

NV ouroboros_sv_nv(pTHX_ SV* sv) {
    return SvNV(sv);
}

char* ouroboros_sv_pv(pTHX_ SV* sv, STRLEN* len) {
    return SvPV(sv, *len);
}

SV* ouroboros_sv_rv(pTHX_ SV* sv) {
    return SvRV(sv);
}

svtype ouroboros_sv_type(pTHX_ SV* sv) {
    return SvTYPE(sv);
}

UV ouroboros_sv_flags(pTHX_ SV* sv) {
    return SvFLAGS(sv);
}

/* SV value setters */

void ouroboros_sv_iv_set(pTHX_ SV* sv, IV val) {
    SvIV_set(sv, val);
}

void ouroboros_sv_uv_set(pTHX_ SV* sv, UV val) {
    SvUV_set(sv, val);
}

void ouroboros_sv_nv_set(pTHX_ SV* sv, NV val) {
    SvNV_set(sv, val);
}

void ouroboros_sv_rv_set(pTHX_ SV* sv, SV* val) {
    SvRV_set(sv, val);
}

/* SV string accessors */

STRLEN ouroboros_sv_pv_cur(pTHX_ SV* sv) {
    return SvCUR(sv);
}

STRLEN ouroboros_sv_pv_len(pTHX_ SV* sv) {
    return SvLEN(sv);
}

char* ouroboros_sv_pv_end(pTHX_ SV* sv) {
    return SvEND(sv);
}

/* Reference counting */

U32 ouroboros_sv_refcnt(pTHX_ SV* sv) {
    return SvREFCNT(sv);
}

SV* ouroboros_sv_refcnt_inc(pTHX_ SV* sv) {
    return SvREFCNT_inc(sv);
}

void ouroboros_sv_refcnt_inc_void_nn(pTHX_ SV* sv) {
    SvREFCNT_inc_void_NN(sv);
}

void ouroboros_sv_refcnt_dec(pTHX_ SV* sv) {
    SvREFCNT_dec(sv);
}

void ouroboros_sv_refcnt_dec_nn(pTHX_ SV* sv) {
    SvREFCNT_dec_NN(sv);
}

/* Magic */

void ouroboros_sv_get_magic(pTHX_ SV* sv) {
    mg_get(sv);
}

void ouroboros_sv_set_magic(pTHX_ SV* sv) {
    mg_set(sv);
}

/* GV accessors */

SV* ouroboros_gv_sv(pTHX_ GV* gv) {
    return GvSV(gv);
}

AV* ouroboros_gv_av(pTHX_ GV* gv) {
    return GvAV(gv);
}

HV* ouroboros_gv_hv(pTHX_ GV* gv) {
    return GvHV(gv);
}

CV* ouroboros_gv_cv(pTHX_ GV* gv) {
    return GvCV(gv);
}

/* HV name functions */

const char* ouroboros_hv_name(pTHX_ HV* hv) {
    return HvNAME(hv);
}

STRLEN ouroboros_hv_name_len(pTHX_ HV* hv) {
    return HvNAMELEN(hv);
}

unsigned char ouroboros_hv_name_utf8(pTHX_ HV* hv) {
    return HvNAMEUTF8(hv) ? 1 : 0;
}

const char* ouroboros_hv_ename(pTHX_ HV* hv) {
    return HvENAME(hv);
}

STRLEN ouroboros_hv_ename_len(pTHX_ HV* hv) {
    return HvENAMELEN(hv);
}

unsigned char ouroboros_hv_ename_utf8(pTHX_ HV* hv) {
    return HvENAMEUTF8(hv) ? 1 : 0;
}

/* HE functions */

const char* ouroboros_he_pv(pTHX_ HE* he, STRLEN* len) {
    return HePV(he, *len);
}

SV* ouroboros_he_val(pTHX_ HE* he) {
    return HeVAL(he);
}

U32 ouroboros_he_hash(pTHX_ HE* he) {
    return HeHASH(he);
}

SV* ouroboros_he_svkey(pTHX_ HE* he) {
    return HeSVKEY(he);
}

/* Hash function */

U32 ouroboros_perl_hash(pTHX_ const char* key, STRLEN len) {
    U32 hash;
    PERL_HASH(hash, key, len);
    return hash;
}

/* Scope management */

void ouroboros_enter(pTHX) {
    ENTER;
}

void ouroboros_leave(pTHX) {
    LEAVE;
}

void ouroboros_savetmps(pTHX) {
    SAVETMPS;
}

void ouroboros_freetmps(pTHX) {
    FREETMPS;
}

/* Exception handling */

int ouroboros_xcpt_try(pTHX_ ouroboros_xcpt_callback_t cb, void* arg) {
    dJMPENV;
    int rc;

    JMPENV_PUSH(rc);
    if (rc == 0) {
        cb(aTHX_ arg);
    }
    JMPENV_POP;

    return rc;
}

void ouroboros_xcpt_rethrow(pTHX) {
    croak_sv(ERRSV);
}

/* Context */

U8 ouroboros_gimme(pTHX) {
    return GIMME_V;
}

/* Global SVs */

SV* ouroboros_sv_undef(pTHX) {
    return &PL_sv_undef;
}

SV* ouroboros_sv_no(pTHX) {
    return &PL_sv_no;
}

SV* ouroboros_sv_yes(pTHX) {
    return &PL_sv_yes;
}
