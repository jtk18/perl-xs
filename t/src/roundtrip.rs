//! Roundtrip tests for passing data between Perl and Rust XS.

use perl_xs::convert::IntoSV;
use perl_xs::{AV, HV, IV, NV, SV, UV};

xs! {
    package XSTest::Roundtrip;

    // INTEGER TESTS

    sub roundtrip_iv(ctx, val: IV) {
        val
    }

    sub roundtrip_uv(ctx, val: UV) {
        val
    }

    sub add_iv(ctx, a: IV, b: IV) {
        a + b
    }

    sub negate_iv(ctx, val: IV) {
        -val
    }

    sub iv_boundaries(ctx) {
        (IV::MIN, IV::MAX, 0 as IV)
    }

    sub uv_max(ctx) {
        UV::MAX
    }

    // FLOAT TESTS

    sub roundtrip_nv(ctx, val: NV) {
        val
    }

    sub multiply_nv(ctx, a: NV, b: NV) {
        a * b
    }

    sub nv_special_values(ctx) {
        (0.0 as NV, -0.0 as NV, NV::INFINITY, NV::NEG_INFINITY)
    }

    sub nv_precision(ctx) {
        3.141592653589793 as NV
    }

    // STRING TESTS

    sub roundtrip_string(ctx, s: String) {
        s
    }

    sub string_length(ctx, s: String) {
        s.len() as IV
    }

    sub unicode_string(ctx) {
        "Hello, 世界! 🌍"
    }

    sub various_strings(ctx) {
        (
            "ASCII only",
            "UTF-8: café résumé naïve",
            "CJK: 漢字 한글 ひらがな",
            "Emoji: 😀🎉🚀",
            "Mixed: Hello 世界 🌍!",
        )
    }

    sub empty_string(ctx) {
        ""
    }

    sub binary_string(ctx) {
        ctx.new_sv("binary\x00with\x00nulls")
    }

    // BOOLEAN TESTS

    sub roundtrip_bool(ctx, val: bool) {
        val
    }

    sub bool_values(ctx) {
        (true, false)
    }

    // ARRAYREF TESTS

    sub create_empty_array(ctx) {
        ctx.new_av()
    }

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

    sub create_mixed_array(ctx) {
        let av = ctx.new_av();
        let perl = ctx.perl();
        av.store(0, (42 as IV).into_sv(perl));
        av.store(1, (3.14 as NV).into_sv(perl));
        av.store(2, "hello".into_sv(perl));
        av.store(3, true.into_sv(perl));
        av
    }

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

    sub sum_array(ctx, av: AV) {
        let sum: IV = av.iter().filter_map(|v| v).map(|sv: SV| sv.iv()).sum();
        sum
    }

    sub array_length(ctx, av: AV) {
        av.top_index() + 1
    }

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

    // HASHREF TESTS

    sub create_empty_hash(ctx) {
        ctx.new_hv()
    }

    sub create_int_hash(ctx) {
        let hv = ctx.new_hv();
        let perl = ctx.perl();
        hv.store("one", (1 as IV).into_sv(perl));
        hv.store("two", (2 as IV).into_sv(perl));
        hv.store("three", (3 as IV).into_sv(perl));
        hv
    }

    sub create_mixed_hash(ctx) {
        let hv = ctx.new_hv();
        let perl = ctx.perl();
        hv.store("integer", (42 as IV).into_sv(perl));
        hv.store("float", (3.14 as NV).into_sv(perl));
        hv.store("string", "hello world".into_sv(perl));
        hv.store("boolean", true.into_sv(perl));
        hv
    }

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

    sub sum_hash_values(ctx, hv: HV) {
        let sum: IV = hv.values::<IV>().sum();
        sum
    }

    sub hash_key_count(ctx, hv: HV) {
        hv.keys().count() as IV
    }

    sub hash_fetch(ctx, hv: HV, key: String) {
        hv.fetch::<SV>(&key)
    }

    sub hash_exists(ctx, hv: HV, key: String) {
        hv.exists(&key)
    }

    sub create_unicode_key_hash(ctx) {
        let hv = ctx.new_hv();
        let perl = ctx.perl();
        hv.store("ascii", (1 as IV).into_sv(perl));
        hv.store("日本語", (2 as IV).into_sv(perl));
        hv.store("emoji🎉", (3 as IV).into_sv(perl));
        hv
    }

    // MIXED DATA STRUCTURE TESTS

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

    // OPTIONAL/UNDEF TESTS

    sub return_undef(ctx) {
        ctx.sv_undef()
    }

    sub optional_iv(ctx, val: Option<IV>) {
        val.unwrap_or(-1)
    }

    sub optional_string(ctx, val: Option<IV>) {
        match val {
            Some(v) => v,
            None => 0,
        }
    }

    // TYPE CHECKING TESTS

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

    sub is_defined(ctx, sv: SV) {
        sv.ok()
    }

    // PERL OBJECT TESTS

    sub counter_new(ctx, class: String, initial: IV) {
        use std::cell::RefCell;
        ctx.new_sv_with_data(RefCell::new(initial)).bless(&class)
    }

    sub counter_get(_ctx, this: perl_xs::DataRef<std::cell::RefCell<IV>>) {
        *this.borrow()
    }

    sub counter_inc(_ctx, this: perl_xs::DataRef<std::cell::RefCell<IV>>, amount: Option<IV>) {
        *this.borrow_mut() += amount.unwrap_or(1);
    }

    sub counter_dec(_ctx, this: perl_xs::DataRef<std::cell::RefCell<IV>>, amount: Option<IV>) {
        *this.borrow_mut() -= amount.unwrap_or(1);
    }

    // STRESS/EDGE CASE TESTS

    sub create_large_array(ctx, size: IV) {
        let av = ctx.new_av();
        let perl = ctx.perl();
        for i in 0..size {
            av.store(i as perl_xs::SSize_t, i.into_sv(perl));
        }
        av
    }

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
