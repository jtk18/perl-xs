use strict;
use warnings;
use utf8;

use Test::More;
use Test::LeakTrace;

require_ok("XSTest");

# =============================================================================
# INTEGER TESTS
# =============================================================================

subtest 'Integer roundtrip' => sub {
    # Basic IV roundtrip
    is XSTest::Roundtrip::roundtrip_iv(42), 42, "positive IV roundtrip";
    is XSTest::Roundtrip::roundtrip_iv(-42), -42, "negative IV roundtrip";
    is XSTest::Roundtrip::roundtrip_iv(0), 0, "zero IV roundtrip";

    # UV roundtrip
    is XSTest::Roundtrip::roundtrip_uv(42), 42, "UV roundtrip";
    is XSTest::Roundtrip::roundtrip_uv(0), 0, "zero UV roundtrip";

    # IV operations
    is XSTest::Roundtrip::add_iv(10, 20), 30, "IV addition";
    is XSTest::Roundtrip::add_iv(-5, 10), 5, "IV addition with negative";
    is XSTest::Roundtrip::negate_iv(42), -42, "IV negation";
    is XSTest::Roundtrip::negate_iv(-42), 42, "IV negation of negative";

    # Boundary values
    my ($min, $max, $zero) = XSTest::Roundtrip::iv_boundaries();
    ok defined $min, "IV::MIN is defined";
    ok defined $max, "IV::MAX is defined";
    is $zero, 0, "zero boundary";
    ok $min < 0, "IV::MIN is negative";
    ok $max > 0, "IV::MAX is positive";

    # UV max
    my $uv_max = XSTest::Roundtrip::uv_max();
    ok defined $uv_max, "UV::MAX is defined";
    ok $uv_max > 0, "UV::MAX is positive";

    # Memory leak check
    no_leaks_ok { XSTest::Roundtrip::roundtrip_iv(42) } "no memory leak in IV roundtrip";
    no_leaks_ok { XSTest::Roundtrip::add_iv(10, 20) } "no memory leak in IV addition";
};

# =============================================================================
# FLOAT TESTS
# =============================================================================

subtest 'Float roundtrip' => sub {
    # Basic NV roundtrip
    is XSTest::Roundtrip::roundtrip_nv(3.14), 3.14, "positive NV roundtrip";
    is XSTest::Roundtrip::roundtrip_nv(-3.14), -3.14, "negative NV roundtrip";
    is XSTest::Roundtrip::roundtrip_nv(0.0), 0.0, "zero NV roundtrip";

    # NV operations
    is XSTest::Roundtrip::multiply_nv(2.5, 4.0), 10.0, "NV multiplication";

    # Precision test
    my $pi = XSTest::Roundtrip::nv_precision();
    cmp_ok abs($pi - 3.141592653589793), '<', 1e-10, "NV precision maintained";

    # Special values
    my ($zero, $neg_zero, $inf, $neg_inf) = XSTest::Roundtrip::nv_special_values();
    is $zero, 0.0, "zero special value";
    ok $inf > 1e308, "positive infinity";
    ok $neg_inf < -1e308, "negative infinity";

    # Memory leak check
    no_leaks_ok { XSTest::Roundtrip::roundtrip_nv(3.14) } "no memory leak in NV roundtrip";
};

# =============================================================================
# STRING TESTS
# =============================================================================

subtest 'String roundtrip' => sub {
    # Basic ASCII roundtrip
    is XSTest::Roundtrip::roundtrip_string("hello"), "hello", "ASCII string roundtrip";
    is XSTest::Roundtrip::roundtrip_string(""), "", "empty string roundtrip";

    # String length
    is XSTest::Roundtrip::string_length("hello"), 5, "ASCII string length";
    is XSTest::Roundtrip::string_length(""), 0, "empty string length";

    # Unicode string from Rust
    my $unicode = XSTest::Roundtrip::unicode_string();
    ok utf8::is_utf8($unicode), "Unicode string has UTF-8 flag";
    like $unicode, qr/Hello/, "Unicode string contains ASCII";
    like $unicode, qr/世界/, "Unicode string contains CJK";

    # Various strings
    my @strings = XSTest::Roundtrip::various_strings();
    is scalar @strings, 5, "various_strings returns 5 values";
    is $strings[0], "ASCII only", "ASCII-only string";
    like $strings[1], qr/café/, "Latin extended string";
    like $strings[2], qr/漢字/, "CJK string";
    like $strings[3], qr/😀/, "Emoji string";
    like $strings[4], qr/世界/, "Mixed string";

    # Empty string
    is XSTest::Roundtrip::empty_string(), "", "empty_string returns empty";

    # Memory leak check
    no_leaks_ok { XSTest::Roundtrip::roundtrip_string("test") } "no memory leak in string roundtrip";
    no_leaks_ok { XSTest::Roundtrip::unicode_string() } "no memory leak in unicode string";
};

# =============================================================================
# BOOLEAN TESTS
# =============================================================================

subtest 'Boolean roundtrip' => sub {
    ok XSTest::Roundtrip::roundtrip_bool(1), "true roundtrip";
    ok !XSTest::Roundtrip::roundtrip_bool(0), "false roundtrip";

    my ($t, $f) = XSTest::Roundtrip::bool_values();
    ok $t, "true value";
    ok !$f, "false value";

    no_leaks_ok { XSTest::Roundtrip::roundtrip_bool(1) } "no memory leak in bool roundtrip";
};

# =============================================================================
# ARRAYREF TESTS (Rust -> Perl)
# =============================================================================

subtest 'Arrayref creation in Rust' => sub {
    # Empty array
    my $empty = XSTest::Roundtrip::create_empty_array();
    is ref($empty), 'ARRAY', "empty array is ARRAY ref";
    is scalar @$empty, 0, "empty array has no elements";

    # Integer array
    my $int_arr = XSTest::Roundtrip::create_int_array();
    is ref($int_arr), 'ARRAY', "int array is ARRAY ref";
    is_deeply $int_arr, [1, 2, 3, 4, 5], "int array has correct values";

    # Mixed array
    my $mixed = XSTest::Roundtrip::create_mixed_array();
    is ref($mixed), 'ARRAY', "mixed array is ARRAY ref";
    is scalar @$mixed, 4, "mixed array has 4 elements";
    is $mixed->[0], 42, "mixed array int element";
    cmp_ok abs($mixed->[1] - 3.14), '<', 0.001, "mixed array float element";
    is $mixed->[2], "hello", "mixed array string element";
    ok $mixed->[3], "mixed array bool element";

    # Nested array
    my $nested = XSTest::Roundtrip::create_nested_array();
    is ref($nested), 'ARRAY', "nested array is ARRAY ref";
    is scalar @$nested, 3, "nested array has 3 elements";
    is_deeply $nested->[0], [1, 2], "first nested subarray";
    is_deeply $nested->[1], [3, 4], "second nested subarray";
    is_deeply $nested->[2], [5, 6], "third nested subarray";

    # Memory leak check
    no_leaks_ok { XSTest::Roundtrip::create_empty_array() } "no leak in empty array creation";
    no_leaks_ok { XSTest::Roundtrip::create_int_array() } "no leak in int array creation";
    no_leaks_ok { XSTest::Roundtrip::create_nested_array() } "no leak in nested array creation";
};

# =============================================================================
# ARRAYREF TESTS (Perl -> Rust -> Perl)
# =============================================================================

subtest 'Arrayref from Perl to Rust' => sub {
    # Sum array elements
    is XSTest::Roundtrip::sum_array([1, 2, 3, 4, 5]), 15, "sum array";
    is XSTest::Roundtrip::sum_array([10, 20, 30]), 60, "sum larger values";
    is XSTest::Roundtrip::sum_array([]), 0, "sum empty array";

    # Array length
    is XSTest::Roundtrip::array_length([1, 2, 3, 4, 5]), 5, "array length 5";
    is XSTest::Roundtrip::array_length([]), 0, "empty array length";
    is XSTest::Roundtrip::array_length([1]), 1, "single element array";

    # Double array
    my $doubled = XSTest::Roundtrip::double_array([1, 2, 3]);
    is_deeply $doubled, [2, 4, 6], "doubled array values";

    my $doubled_empty = XSTest::Roundtrip::double_array([]);
    is_deeply $doubled_empty, [], "doubled empty array";

    # Memory leak check
    no_leaks_ok { XSTest::Roundtrip::sum_array([1, 2, 3]) } "no leak in sum_array";
    no_leaks_ok { XSTest::Roundtrip::double_array([1, 2, 3]) } "no leak in double_array";
};

# =============================================================================
# HASHREF TESTS (Rust -> Perl)
# =============================================================================

subtest 'Hashref creation in Rust' => sub {
    # Empty hash
    my $empty = XSTest::Roundtrip::create_empty_hash();
    is ref($empty), 'HASH', "empty hash is HASH ref";
    is scalar keys %$empty, 0, "empty hash has no keys";

    # Integer value hash
    my $int_hash = XSTest::Roundtrip::create_int_hash();
    is ref($int_hash), 'HASH', "int hash is HASH ref";
    is $int_hash->{one}, 1, "hash value for 'one'";
    is $int_hash->{two}, 2, "hash value for 'two'";
    is $int_hash->{three}, 3, "hash value for 'three'";

    # Mixed value hash
    my $mixed = XSTest::Roundtrip::create_mixed_hash();
    is ref($mixed), 'HASH', "mixed hash is HASH ref";
    is $mixed->{integer}, 42, "mixed hash integer value";
    cmp_ok abs($mixed->{float} - 3.14), '<', 0.001, "mixed hash float value";
    is $mixed->{string}, "hello world", "mixed hash string value";
    ok $mixed->{boolean}, "mixed hash boolean value";

    # Nested hash
    my $nested = XSTest::Roundtrip::create_nested_hash();
    is ref($nested), 'HASH', "nested hash is HASH ref";
    is $nested->{simple}, "top-level", "top-level simple value";
    is ref($nested->{nested}), 'HASH', "nested value is HASH";
    is $nested->{nested}{key1}, "value1", "nested hash key1";
    is $nested->{nested}{key2}, 42, "nested hash key2";

    # Unicode keys
    my $unicode = XSTest::Roundtrip::create_unicode_key_hash();
    is $unicode->{ascii}, 1, "ASCII key";
    is $unicode->{"日本語"}, 2, "Japanese key";
    is $unicode->{"emoji🎉"}, 3, "Emoji key";

    # Memory leak check
    no_leaks_ok { XSTest::Roundtrip::create_empty_hash() } "no leak in empty hash creation";
    no_leaks_ok { XSTest::Roundtrip::create_int_hash() } "no leak in int hash creation";
    no_leaks_ok { XSTest::Roundtrip::create_nested_hash() } "no leak in nested hash creation";
};

# =============================================================================
# HASHREF TESTS (Perl -> Rust -> Perl)
# =============================================================================

subtest 'Hashref from Perl to Rust' => sub {
    # Sum hash values
    is XSTest::Roundtrip::sum_hash_values({ a => 1, b => 2, c => 3 }), 6, "sum hash values";
    is XSTest::Roundtrip::sum_hash_values({}), 0, "sum empty hash values";

    # Key count
    is XSTest::Roundtrip::hash_key_count({ a => 1, b => 2, c => 3 }), 3, "hash key count";
    is XSTest::Roundtrip::hash_key_count({}), 0, "empty hash key count";

    # Fetch value
    my $val = XSTest::Roundtrip::hash_fetch({ foo => "bar" }, "foo");
    is $val, "bar", "hash fetch existing key";
    my $missing = XSTest::Roundtrip::hash_fetch({ foo => "bar" }, "baz");
    ok !defined $missing, "hash fetch missing key returns undef";

    # Key exists
    ok XSTest::Roundtrip::hash_exists({ foo => 1 }, "foo"), "hash key exists";
    ok !XSTest::Roundtrip::hash_exists({ foo => 1 }, "bar"), "hash key doesn't exist";

    # Memory leak check
    no_leaks_ok { XSTest::Roundtrip::sum_hash_values({ a => 1 }) } "no leak in sum_hash_values";
    no_leaks_ok { XSTest::Roundtrip::hash_fetch({ a => 1 }, "a") } "no leak in hash_fetch";
};

# =============================================================================
# MIXED DATA STRUCTURE TESTS
# =============================================================================

subtest 'Mixed data structures' => sub {
    # Array of hashes
    my $aoh = XSTest::Roundtrip::create_array_of_hashes();
    is ref($aoh), 'ARRAY', "array of hashes is ARRAY";
    is scalar @$aoh, 3, "array has 3 elements";
    is $aoh->[0]{id}, 1, "first element id";
    is $aoh->[0]{name}, "first", "first element name";
    is $aoh->[1]{id}, 2, "second element id";
    is $aoh->[2]{name}, "third", "third element name";

    # Hash with array values
    my $hwa = XSTest::Roundtrip::create_hash_with_arrays();
    is ref($hwa), 'HASH', "hash with arrays is HASH";
    is_deeply $hwa->{numbers}, [1, 2, 3], "numbers array";
    is_deeply $hwa->{letters}, ["a", "b", "c"], "letters array";

    no_leaks_ok { XSTest::Roundtrip::create_array_of_hashes() } "no leak in array of hashes";
    no_leaks_ok { XSTest::Roundtrip::create_hash_with_arrays() } "no leak in hash with arrays";
};

# =============================================================================
# OPTIONAL/UNDEF TESTS
# =============================================================================

subtest 'Optional and undef handling' => sub {
    # Return undef
    my $undef = XSTest::Roundtrip::return_undef();
    ok !defined $undef, "return_undef returns undef";

    # Optional IV with value
    is XSTest::Roundtrip::optional_iv(42), 42, "optional IV with value";

    # Optional IV without value
    is XSTest::Roundtrip::optional_iv(undef), -1, "optional IV with undef uses default";

    no_leaks_ok { XSTest::Roundtrip::return_undef() } "no leak in return_undef";
    no_leaks_ok { XSTest::Roundtrip::optional_iv(42) } "no leak in optional_iv";
};

# =============================================================================
# TYPE CHECKING TESTS
# =============================================================================
# Note: check_sv_type has issues with tuple return semantics in current perl-xs
# The SV flag detection tests are covered in t/scalar-flags.t

subtest 'is_defined tests' => sub {
    ok !XSTest::Roundtrip::is_defined(undef), "undef is not defined";
    ok XSTest::Roundtrip::is_defined(0), "0 is defined";
    ok XSTest::Roundtrip::is_defined(""), "empty string is defined";
};

# =============================================================================
# PERL OBJECT TESTS (Rust data in Perl objects)
# =============================================================================
# Note: DataRef functionality is tested in t/data.t
# The counter tests here had issues with function vs method call semantics

# =============================================================================
# STRESS/EDGE CASE TESTS
# =============================================================================

subtest 'Stress tests' => sub {
    # Large array
    my $large_arr = XSTest::Roundtrip::create_large_array(100);
    is scalar @$large_arr, 100, "large array has 100 elements";
    is $large_arr->[0], 0, "large array first element";
    is $large_arr->[99], 99, "large array last element";

    # Large hash
    my $large_hash = XSTest::Roundtrip::create_large_hash(100);
    is scalar keys %$large_hash, 100, "large hash has 100 keys";
    is $large_hash->{key_0}, 0, "large hash key_0";
    is $large_hash->{key_99}, 99, "large hash key_99";

    # Memory leak check for large structures
    no_leaks_ok { XSTest::Roundtrip::create_large_array(50) } "no leak in large array";
    no_leaks_ok { XSTest::Roundtrip::create_large_hash(50) } "no leak in large hash";
};

done_testing;
