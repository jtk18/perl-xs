use strict;
use warnings;

use Test::More;
use Test::LeakTrace;
use utf8;

require_ok("XSTest");

my $hv;

for my $hv ({}, get_rxs_hv()) {
    XSTest::Hash::test_store($hv, "Don't panic!", 42);
    is_deeply $hv, { "Don't panic!" => 42 }, "store latin1";
}

no_leaks_ok { XSTest::Hash::test_store({}, "Don't panic!", 42); };
no_leaks_ok { XSTest::Hash::test_store({}, "Don't panic!", get_rxs_hv()); };

for my $hv ({}, get_rxs_hv()) {
    XSTest::Hash::test_store($hv, "Nu intrat\x{0326}i i\x{0302}n panica\x{0306}!", 42);
    is_deeply $hv, { "Nu intrat\x{0326}i i\x{0302}n panica\x{0306}!" => 42 }, "store unicode";
}

no_leaks_ok { XSTest::Hash::test_store({}, "Nu intrat\x{0326}i i\x{0302}n panica\x{0306}!", 42); };
no_leaks_ok { XSTest::Hash::test_store({}, "Nu intrat\x{0326}i i\x{0302}n panica\x{0306}!", get_rxs_hv()); };

for my $hv (get_hv_pair({ "Don't panic!" => 42 })) {
    is XSTest::Hash::test_exists($hv, "Don't panic!"), 1, "exists";
    XSTest::Hash::test_clear($hv);
    is_deeply $hv, {}, "clear";
}

for my $hv (get_hv_pair({ "Don't panic!" => 42 })) {
    no_leaks_ok { XSTest::Hash::test_clear($hv) };
    is keys @$hv, 0, "cleared the hv from rust xs";
    no_leaks_ok { keys @$hv };
}

for my $hv (get_hv_pair({ "Don't panic!" => 42 })) {
    is XSTest::Hash::test_delete($hv, "Don't panic!"), 42, "delete returns value";
    is_deeply $hv, {}, "delete removes value";
}

for my $hv (get_hv_pair({ "Don't panic!" => 42 })) {
    no_leaks_ok { XSTest::Hash::test_delete($hv, "Don't panic!" ); };
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    is XSTest::Hash::test_iter($hv), 4321, "hash iter";
    is XSTest::Hash::test_iter(get_rxs_hv_filled($hv)), 4321, "hash iter";
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    no_leaks_ok { XSTest::Hash::test_iter($hv); };
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    is XSTest::Hash::test_values($hv), 4321, "hash values";
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    no_leaks_ok { XSTest::Hash::test_values($hv); };
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    is XSTest::Hash::test_keys($hv), 4321, "hash keys";
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    no_leaks_ok { XSTest::Hash::test_keys($hv); };
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    is XSTest::Hash::test_for($hv), 4321, "hash in for loop";
}

for my $hv (get_hv_pair({ a => 1, b => 20, c => 300, d => 4000 })) {
    no_leaks_ok { XSTest::Hash::test_for($hv); };
}

done_testing;

sub get_rxs_hv {
    my %hv = XSTest::Hash::test_new();
    return \%hv;
}

sub get_rxs_hv_filled {
    my ($input_hr) = @_;
    my %hv = XSTest::Hash::test_new();
    @hv{keys %$input_hr} = values %$input_hr;
    return \%hv;
}

sub get_hv_pair {
    my ($input_hr) = @_;

    return ($input_hr, get_rxs_hv_filled($input_hr));
}