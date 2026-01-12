//! Roundtrip tests for passing data between Perl and Rust XS.
//!
//! Tests for:
//! - Primitive types (integers, floats, strings)
//! - References (arrayrefs, hashrefs)
//! - Complex data structures
//! - Perl objects
//! - Coderefs (calling Perl subs from Rust)

use perl_xs::convert::IntoSV;
use perl_xs::{AV, HV, IV, NV, SV, UV};

xs! {
    package XSTest::Roundtrip;

    // ========================================================================
    // INTEGER TESTS
    // ========================================================================

    /// Return the same IV value (signed integer roundtrip)
    sub roundtrip_iv(ctx, val: IV) {
        val
    }

    /// Return the same UV value (unsigned integer roundtrip)
    sub roundtrip_uv(ctx, val: UV) {
        val
    }

    /// Return the sum of two IVs
    sub add_iv(ctx, a: IV, b: IV) {
        a + b
    }

    /// Return a negative IV
    sub negate_iv(ctx, val: IV) {
        -val
    }

    /// Return IV min/max values for testing boundary conditions
    sub iv_boundaries(ctx) {
        (IV::MIN, IV::MAX, 0 as IV)
    }

    /// Return UV max value
    sub uv_max(ctx) {
        UV::MAX
    }

    // ========================================================================
    // FLOAT TESTS
    // ========================================================================

    /// Return the same NV value (float roundtrip)
    sub roundtrip_nv(ctx, val: NV) {
        val
    }

    /// Return product of two NVs
    sub multiply_nv(ctx, a: NV, b: NV) {
        a * b
    }

    /// Return special float values
    sub nv_special_values(ctx) {
        (0.0 as NV, -0.0 as NV, NV::INFINITY, NV::NEG_INFINITY)
    }

    /// Return a precise float value (for precision tests)
    sub nv_precision(ctx) {
        3.141592653589793 as NV
    }

    // ========================================================================
    // STRING TESTS
    // ========================================================================

    /// Return the same string (ASCII roundtrip)
    sub roundtrip_string(ctx, s: String) {
        s
    }

    /// Return the length of a string
    sub string_length(ctx, s: String) {
        s.len() as IV
    }

    /// Return a string with Unicode characters
    sub unicode_string(ctx) {
        "Hello, 世界! 🌍"
    }

    /// Return multiple strings with various content
    sub various_strings(ctx) {
        (
            "ASCII only",
            "UTF-8: café résumé naïve",
            "CJK: 漢字 한글 ひらがな",
            "Emoji: 😀🎉🚀",
            "Mixed: Hello 世界 🌍!",
        )
    }

    /// Return an empty string
    sub empty_string(ctx) {
        ""
    }

    /// Return a string with null bytes (via SV)
    sub binary_string(ctx) {
        ctx.new_sv("binary\x00with\x00nulls")
    }

    // ========================================================================
    // BOOLEAN TESTS
    // ========================================================================

    /// Return the same boolean value
    sub roundtrip_bool(ctx, val: bool) {
        val
    }

    /// Return both boolean values
    sub bool_values(ctx) {
        (true, false)
    }

    // ========================================================================
    // ARRAYREF TESTS (Creating arrays in Rust, returning to Perl)
    // ========================================================================

    /// Create and return an empty arrayref
    sub create_empty_array(ctx) {
        ctx.new_av()
    }

    /// Create and return an arrayref with integer elements
    sub create_int_array(ctx) {
        let av = ctx.new_av();
        let perl = ctx.perl();
        av.store(0, (1 as IV).into_sv(perl));
        av.store(1, (2 as IV).into_sv(perl));
        av.store(2, (3 as IV).into_sv(perl));
        av.store(3, (4 as IV).into_sv(perl));
        av.store(4, (5 as IV).into_sv(perl));
        av
    }

    /// Create and return an arrayref with mixed elements
    sub create_mixed_array(ctx) {
        let av = ctx.new_av();
        let perl = ctx.perl();
        av.store(0, (42 as IV).into_sv(perl));
        av.store(1, (3.14 as NV).into_sv(perl));
        av.store(2, "hello".into_sv(perl));
        av.store(3, true.into_sv(perl));
        av
    }

    /// Create a nested arrayref [[1,2], [3,4], [5,6]]
    sub create_nested_array(ctx) {
        let perl = ctx.perl();

        let inner1 = ctx.new_av();
        inner1.store(0, (1 as IV).into_sv(perl));
        inner1.store(1, (2 as IV).into_sv(perl));

        let inner2 = ctx.new_av();
        inner2.store(0, (3 as IV).into_sv(perl));
        inner2.store(1, (4 as IV).into_sv(perl));

        let inner3 = ctx.new_av();
        inner3.store(0, (5 as IV).into_sv(perl));
        inner3.store(1, (6 as IV).into_sv(perl));

        let outer = ctx.new_av();
        outer.store(0, inner1.into_sv(perl));
        outer.store(1, inner2.into_sv(perl));
        outer.store(2, inner3.into_sv(perl));

        outer
    }

    /// Take an arrayref from Perl, sum its elements, return the sum
    sub sum_array(ctx, av: AV) {
        let sum: IV = av.iter().filter_map(|v| v).map(|sv: SV| sv.iv()).sum();
        sum
    }

    /// Take an arrayref and return its length
    sub array_length(ctx, av: AV) {
        av.top_index() + 1
    }

    /// Double each element of an array and return new array
    sub double_array(ctx, av: AV) {
        let perl = ctx.perl();
        let result = ctx.new_av();
        let mut idx = 0;
        for val in av.iter::<IV>() {
            if let Some(v) = val {
                result.store(idx, (v * 2).into_sv(perl));
                idx += 1;
            }
        }
        result
    }

    // ========================================================================
    // HASHREF TESTS (Creating hashes in Rust, returning to Perl)
    // ========================================================================

    /// Create and return an empty hashref
    sub create_empty_hash(ctx) {
        ctx.new_hv()
    }

    /// Create and return a hashref with string keys and integer values
    sub create_int_hash(ctx) {
        let hv = ctx.new_hv();
        let perl = ctx.perl();
        hv.store("one", (1 as IV).into_sv(perl));
        hv.store("two", (2 as IV).into_sv(perl));
        hv.store("three", (3 as IV).into_sv(perl));
        hv
    }

    /// Create and return a hashref with mixed values
    sub create_mixed_hash(ctx) {
        let hv = ctx.new_hv();
        let perl = ctx.perl();
        hv.store("integer", (42 as IV).into_sv(perl));
        hv.store("float", (3.14 as NV).into_sv(perl));
        hv.store("string", "hello world".into_sv(perl));
        hv.store("boolean", true.into_sv(perl));
        hv
    }

    /// Create a nested hashref { outer => { inner => value } }
    sub create_nested_hash(ctx) {
        let perl = ctx.perl();

        let inner = ctx.new_hv();
        inner.store("key1", "value1".into_sv(perl));
        inner.store("key2", (42 as IV).into_sv(perl));

        let outer = ctx.new_hv();
        outer.store("nested", inner.into_sv(perl));
        outer.store("simple", "top-level".into_sv(perl));

        outer
    }

    /// Take a hashref from Perl, sum its integer values
    sub sum_hash_values(ctx, hv: HV) {
        let sum: IV = hv.values::<IV>().sum();
        sum
    }

    /// Take a hashref and return the number of keys
    sub hash_key_count(ctx, hv: HV) {
        hv.keys().count() as IV
    }

    /// Fetch a value from hashref by key
    sub hash_fetch(ctx, hv: HV, key: String) {
        hv.fetch::<SV>(&key)
    }

    /// Check if key exists in hashref
    sub hash_exists(ctx, hv: HV, key: String) {
        hv.exists(&key)
    }

    /// Create a hashref with Unicode keys
    sub create_unicode_key_hash(ctx) {
        let hv = ctx.new_hv();
        let perl = ctx.perl();
        hv.store("ascii", (1 as IV).into_sv(perl));
        hv.store("日本語", (2 as IV).into_sv(perl));
        hv.store("emoji🎉", (3 as IV).into_sv(perl));
        hv
    }

    // ========================================================================
    // MIXED DATA STRUCTURE TESTS
    // ========================================================================

    /// Create array of hashes
    sub create_array_of_hashes(ctx) {
        let perl = ctx.perl();
        let av = ctx.new_av();

        let h1 = ctx.new_hv();
        h1.store("id", (1 as IV).into_sv(perl));
        h1.store("name", "first".into_sv(perl));

        let h2 = ctx.new_hv();
        h2.store("id", (2 as IV).into_sv(perl));
        h2.store("name", "second".into_sv(perl));

        let h3 = ctx.new_hv();
        h3.store("id", (3 as IV).into_sv(perl));
        h3.store("name", "third".into_sv(perl));

        av.store(0, h1.into_sv(perl));
        av.store(1, h2.into_sv(perl));
        av.store(2, h3.into_sv(perl));

        av
    }

    /// Create hash with array values
    sub create_hash_with_arrays(ctx) {
        let perl = ctx.perl();
        let hv = ctx.new_hv();

        let arr1 = ctx.new_av();
        arr1.store(0, (1 as IV).into_sv(perl));
        arr1.store(1, (2 as IV).into_sv(perl));
        arr1.store(2, (3 as IV).into_sv(perl));

        let arr2 = ctx.new_av();
        arr2.store(0, "a".into_sv(perl));
        arr2.store(1, "b".into_sv(perl));
        arr2.store(2, "c".into_sv(perl));

        hv.store("numbers", arr1.into_sv(perl));
        hv.store("letters", arr2.into_sv(perl));

        hv
    }

    // ========================================================================
    // OPTIONAL/UNDEF TESTS
    // ========================================================================

    /// Return undef
    sub return_undef(ctx) {
        ctx.sv_undef()
    }

    /// Accept optional IV, return it or default
    sub optional_iv(ctx, val: Option<IV>) {
        val.unwrap_or(-1)
    }

    /// Accept optional string
    sub optional_string(ctx, val: Option<IV>) {
        match val {
            Some(v) => v,
            None => 0,
        }
    }

    // ========================================================================
    // TYPE CHECKING TESTS
    // ========================================================================

    /// Check what type of value was passed
    sub check_sv_type(ctx, sv: SV) {
        (
            sv.ok(),
            sv.is_scalar(),
            sv.is_array(),
            sv.is_hash(),
            sv.is_code(),
            sv.rv_ok(),
        )
    }

    /// Check if value is defined
    sub is_defined(ctx, sv: SV) {
        sv.ok()
    }

    // ========================================================================
    // PERL OBJECT TESTS (using DataRef for Rust data attached to Perl objects)
    // ========================================================================

    /// Create a simple counter object (Perl object wrapping Rust data)
    sub counter_new(ctx, class: String, initial: IV) {
        use std::cell::RefCell;
        ctx.new_sv_with_data(RefCell::new(initial)).bless(&class)
    }

    /// Get counter value
    sub counter_get(_ctx, this: perl_xs::DataRef<std::cell::RefCell<IV>>) {
        *this.borrow()
    }

    /// Increment counter
    sub counter_inc(_ctx, this: perl_xs::DataRef<std::cell::RefCell<IV>>, amount: Option<IV>) {
        *this.borrow_mut() += amount.unwrap_or(1);
    }

    /// Decrement counter
    sub counter_dec(_ctx, this: perl_xs::DataRef<std::cell::RefCell<IV>>, amount: Option<IV>) {
        *this.borrow_mut() -= amount.unwrap_or(1);
    }

    // ========================================================================
    // STRESS/EDGE CASE TESTS
    // ========================================================================

    /// Create a large array
    sub create_large_array(ctx, size: IV) {
        let av = ctx.new_av();
        let perl = ctx.perl();
        for i in 0..size {
            av.store(i as perl_xs::SSize_t, i.into_sv(perl));
        }
        av
    }

    /// Create a hash with many keys
    sub create_large_hash(ctx, size: IV) {
        let hv = ctx.new_hv();
        let perl = ctx.perl();
        for i in 0..size {
            let key = format!("key_{}", i);
            hv.store(&key, i.into_sv(perl));
        }
        hv
    }
}
