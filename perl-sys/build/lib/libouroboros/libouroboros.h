/*
 * libouroboros.h - Minimal Ouroboros header for perl-sys
 *
 * This provides the XS macro wrappers as C functions, allowing
 * Rust to call Perl's XS API safely.
 */

#ifndef LIBOUROBOROS_H
#define LIBOUROBOROS_H

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* C compatibility type for boolean values - matches Rust c_bool */
typedef unsigned char c_bool;

/* Stack object for managing XS stack operations */
typedef struct {
    SV** sp;
    I32 ax;
    I32 items;
    I32 mark;
} ouroboros_stack_t;

/* Exception callback type */
typedef int (*ouroboros_xcpt_callback_t)(pTHX_ void* arg);

/* Stack management functions */
void ouroboros_stack_init(pTHX_ ouroboros_stack_t* stack);
void ouroboros_stack_prepush_return(pTHX_ ouroboros_stack_t* stack);
int ouroboros_stack_items(pTHX_ ouroboros_stack_t* stack);
void ouroboros_stack_putback(pTHX_ ouroboros_stack_t* stack);
SV* ouroboros_stack_fetch(pTHX_ ouroboros_stack_t* stack, SSize_t idx);
void ouroboros_stack_store(pTHX_ ouroboros_stack_t* stack, SSize_t idx, SV* sv);
void ouroboros_stack_extend(pTHX_ ouroboros_stack_t* stack, SSize_t n);
void ouroboros_stack_pushmark(pTHX_ ouroboros_stack_t* stack);
void ouroboros_stack_spagain(pTHX_ ouroboros_stack_t* stack);

/* XPush variants - extend and push */
void ouroboros_stack_xpush_sv(pTHX_ ouroboros_stack_t* stack, SV* sv);
void ouroboros_stack_xpush_sv_mortal(pTHX_ ouroboros_stack_t* stack, SV* sv);
void ouroboros_stack_xpush_iv(pTHX_ ouroboros_stack_t* stack, IV iv);
void ouroboros_stack_xpush_uv(pTHX_ ouroboros_stack_t* stack, UV uv);
void ouroboros_stack_xpush_nv(pTHX_ ouroboros_stack_t* stack, NV nv);
void ouroboros_stack_xpush_pv(pTHX_ ouroboros_stack_t* stack, const char* pv, STRLEN len);
void ouroboros_stack_xpush_mortal(pTHX_ ouroboros_stack_t* stack);

/* Push variants */
void ouroboros_stack_push_sv(pTHX_ ouroboros_stack_t* stack, SV* sv);
void ouroboros_stack_push_sv_mortal(pTHX_ ouroboros_stack_t* stack, SV* sv);
void ouroboros_stack_push_iv(pTHX_ ouroboros_stack_t* stack, IV iv);
void ouroboros_stack_push_uv(pTHX_ ouroboros_stack_t* stack, UV uv);
void ouroboros_stack_push_nv(pTHX_ ouroboros_stack_t* stack, NV nv);
void ouroboros_stack_push_pv(pTHX_ ouroboros_stack_t* stack, const char* pv, STRLEN len);
void ouroboros_stack_push_mortal(pTHX_ ouroboros_stack_t* stack);

/* SV type checks */
unsigned char ouroboros_sv_ok(pTHX_ SV* sv);
unsigned char ouroboros_sv_iok(pTHX_ SV* sv);
unsigned char ouroboros_sv_uok(pTHX_ SV* sv);
unsigned char ouroboros_sv_nok(pTHX_ SV* sv);
unsigned char ouroboros_sv_pok(pTHX_ SV* sv);
unsigned char ouroboros_sv_rok(pTHX_ SV* sv);
unsigned char ouroboros_sv_niok(pTHX_ SV* sv);
unsigned char ouroboros_sv_true(pTHX_ SV* sv);
unsigned char ouroboros_sv_utf8(pTHX_ SV* sv);
unsigned char ouroboros_sv_tainted(pTHX_ SV* sv);
unsigned char ouroboros_sv_is_cow(pTHX_ SV* sv);

/* SV value getters */
IV ouroboros_sv_iv(pTHX_ SV* sv);
UV ouroboros_sv_uv(pTHX_ SV* sv);
NV ouroboros_sv_nv(pTHX_ SV* sv);
char* ouroboros_sv_pv(pTHX_ SV* sv, STRLEN* len);
SV* ouroboros_sv_rv(pTHX_ SV* sv);
svtype ouroboros_sv_type(pTHX_ SV* sv);
UV ouroboros_sv_flags(pTHX_ SV* sv);

/* SV value setters */
void ouroboros_sv_iv_set(pTHX_ SV* sv, IV val);
void ouroboros_sv_uv_set(pTHX_ SV* sv, UV val);
void ouroboros_sv_nv_set(pTHX_ SV* sv, NV val);
void ouroboros_sv_rv_set(pTHX_ SV* sv, SV* val);

/* SV string accessors */
STRLEN ouroboros_sv_pv_cur(pTHX_ SV* sv);
STRLEN ouroboros_sv_pv_len(pTHX_ SV* sv);
char* ouroboros_sv_pv_end(pTHX_ SV* sv);

/* Reference counting */
U32 ouroboros_sv_refcnt(pTHX_ SV* sv);
SV* ouroboros_sv_refcnt_inc(pTHX_ SV* sv);
void ouroboros_sv_refcnt_inc_void_nn(pTHX_ SV* sv);
void ouroboros_sv_refcnt_dec(pTHX_ SV* sv);
void ouroboros_sv_refcnt_dec_nn(pTHX_ SV* sv);

/* Magic */
void ouroboros_sv_get_magic(pTHX_ SV* sv);
void ouroboros_sv_set_magic(pTHX_ SV* sv);

/* GV accessors */
SV* ouroboros_gv_sv(pTHX_ GV* gv);
AV* ouroboros_gv_av(pTHX_ GV* gv);
HV* ouroboros_gv_hv(pTHX_ GV* gv);
CV* ouroboros_gv_cv(pTHX_ GV* gv);

/* HV name functions */
const char* ouroboros_hv_name(pTHX_ HV* hv);
STRLEN ouroboros_hv_name_len(pTHX_ HV* hv);
unsigned char ouroboros_hv_name_utf8(pTHX_ HV* hv);
const char* ouroboros_hv_ename(pTHX_ HV* hv);
STRLEN ouroboros_hv_ename_len(pTHX_ HV* hv);
unsigned char ouroboros_hv_ename_utf8(pTHX_ HV* hv);

/* HE functions */
const char* ouroboros_he_pv(pTHX_ HE* he, STRLEN* len);
SV* ouroboros_he_val(pTHX_ HE* he);
U32 ouroboros_he_hash(pTHX_ HE* he);
SV* ouroboros_he_svkey(pTHX_ HE* he);

/* Hash function */
U32 ouroboros_perl_hash(pTHX_ const char* key, STRLEN len);

/* Scope management */
void ouroboros_enter(pTHX);
void ouroboros_leave(pTHX);
void ouroboros_savetmps(pTHX);
void ouroboros_freetmps(pTHX);

/* Exception handling */
int ouroboros_xcpt_try(pTHX_ ouroboros_xcpt_callback_t cb, void* arg);
void ouroboros_xcpt_save_errsv(pTHX);
SV* ouroboros_xcpt_get_saved_errsv(pTHX);
void ouroboros_xcpt_rethrow(pTHX);
void ouroboros_xcpt_rethrow_with_restore(pTHX);

/* Context */
U8 ouroboros_gimme(pTHX);

/* Global SVs */
SV* ouroboros_sv_undef(pTHX);
SV* ouroboros_sv_no(pTHX);
SV* ouroboros_sv_yes(pTHX);

#endif /* LIBOUROBOROS_H */
