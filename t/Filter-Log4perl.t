#!/usr/bin/env perl

use strict;
use warnings;

use t::MyTest qw/no_plan/;


use_ok('Filter::Log4perl');

run_is();


1;
__END__
=== case: empty source
--- input source
--- expected


==== case: comment-less source
--- input source
my $var = 'comment-less source';
--- expected


==== case: non F::L4P comments source
--- input source
# starting...
my $var = 'comment-less source';
# $var
# got: $var
--- expected


=== case: message only
--- input source
# <debug> a
--- expected
a


=== case: variable only
--- input source
my $var = 'a';
# <debug> $var
--- expected
"a"


=== case: labeled variable
--- input source
my $var = 'b';
# <debug> var = $var
--- expected
var = "b"


=== case: multiple variables
--- input source
my $var_a = 1;
my $var_b = 2;
# <debug> $var_a, $var_b
--- expected
1, 2


=== case: list
--- input source
my @array = qw/a b c/;
# <debug> @array
--- expected
("a", "b", "c")


=== case: hash
--- input source
my %hash = (
    a => 1,
    b => 2,
);
# <debug> %hash
--- expected
("a", 1, "b", 2)


=== case: hash like string (%%)
--- input source
my %hash = (
    a => 1,
);
# <debug> %%hash
--- expected
%hash


=== case: hash like string (%%%)
--- input source
my %hash = (
    a => 1,
);
# <debug> %%%hash
--- expected
%("a", 1)


=== case: hash like string (%%%%)
--- input source
my %hash = (
    a => 1,
);
# <debug> %%%%hash
--- expected
%%hash


=== case: dereference
--- input source
my $var = [ 1, 2, 3 ];
# <debug> @$var
--- expected
(1, 2, 3)


=== case: dereference + index
--- input source
my $var = [ 1, 2, 3 ];
# <debug> $var->[-1]
--- expected
3


=== case: escape sequence
--- input source
my $var = [ 1, 2, 3 ];
# <debug> \$var: $var
--- expected
$var: [1, 2, 3]


=== case: ARRAY
--- input source
$_ = 'dummy';
@_ = qw/a b c/;
# <debug> $_[1]
--- expected
"b"
