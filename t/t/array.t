use strict;
use warnings;

use Test::More;
use Test::LeakTrace;

require_ok("XSTest");

my @rxs_av = XSTest::Array::test_new();
my $perl_av = [];

no_leaks_ok {
    XSTest::Array::test_store($perl_av, 42);
};

no_leaks_ok {
    XSTest::Array::test_store(\@rxs_av, 42);
};

my @subjects = (
    { av => $perl_av, name => "perl originated AV" },
    { av => \@rxs_av, name => "rust xs originated AV"}
);

for my $test ( @subjects ) {
    my ( $av, $subject ) = @{$test}{qw(av name)};
    is scalar @$av, 1, "$subject: array length";
    is $av->[0], 42, "$subject: stored value";

    $av = [ 1, 2 ];
    XSTest::Array::test_clear($av);
    is scalar @$av, 0, "$subject: array cleared";

    $av = [ 42, 42 ];
    is XSTest::Array::test_fetch($av), 1, "$subject: elem defined";
    $av->[0] = undef;
    is XSTest::Array::test_fetch($av), 2, "$subject: elem exists";
    delete $av->[0];
    is XSTest::Array::test_fetch($av), 3, "$subject: elem empty";
    is scalar @$av, 2, "$test: array len is correct";

    $av = [ 1, 2, 3 ];
    is XSTest::Array::test_delete($av), 1, "$subject: delete returns elem";
    is_deeply $av, [ undef, 2, 3 ], "$subject: array elem deleted";
    is XSTest::Array::test_discard($av), undef, "$subject: discard returns undef";
    is_deeply $av, [ undef, undef, 3 ], "$subject: array elem deleted";
    is scalar @$av, 3;

    $av = [ 1 ];
    ok XSTest::Array::test_exists($av), "$subject: defined key exists";
    $av = [ undef ];
    ok XSTest::Array::test_exists($av), "$subject: undef key exists";
    $av = [];
    ok !XSTest::Array::test_exists($av), "$subject: key does not exist";

    $av = [ 1 ];
    XSTest::Array::test_fill($av);
    is_deeply $av, [ 1, undef, undef, undef, undef ], "$subject: array filled";

    is XSTest::Array::test_top_index([]), -1, "$subject: top index of empty array";
    is XSTest::Array::test_top_index([ 1 ]), 0, "$subject: top index of len 1 array";
    is XSTest::Array::test_top_index([ 1, 2, 3 ]), 2, "$subject: top index of len 3 array";

    $av = [ 1, 2 ];
    is XSTest::Array::test_pop($av), 2, "$subject: pop array";
    is XSTest::Array::test_pop($av), 1, "$subject: pop array";
    is XSTest::Array::test_pop($av), undef, "$subject: pop empty array";

    $av = [];
    XSTest::Array::test_push($av, 1);
    XSTest::Array::test_push($av, 2);
    is_deeply $av, [ 1, 2 ], "$subject: push array";

    $av = [ 1, 2 ];
    is XSTest::Array::test_shift($av), 1, "$subject: shift array";
    is XSTest::Array::test_shift($av), 2, "$subject: shift array";
    is XSTest::Array::test_shift($av), undef, "$subject: shift empty array";

    $av = [ 1 ];
    XSTest::Array::test_unshift($av);
    is_deeply $av, [ undef, undef, 1 ], "$subject: unshift array";

    $av = [ 1, 2 ];
    XSTest::Array::test_undef($av);
    is_deeply $av, [], "$subject: undef array";

    $av = [ 1, 20, 300, 4000 ];
    is XSTest::Array::test_iter($av), 4321, "$subject: array iter";
}


done_testing;
