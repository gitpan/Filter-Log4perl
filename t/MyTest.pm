package t::MyTest;

use strict;
use warnings;

use Test::Base -Base;


BEGIN
{
    # WORKAROUND: for Test::Base version less than 0.52.
    if ($Test::Base::VERSION < 0.52) {
        my @test_more_exports = qw/use_ok/;

        require Test::More;
        Test::More->import(import => \@test_more_exports);

        push(our @EXPORT, @test_more_exports);
    }
}


1;


package t::MyTest::Filter;

use strict;
use warnings;

use Test::Base::Filter -Base;

use Log::Log4perl;

# eval() to effects *only* test cases.
eval 'use Filter::Log4perl';


Log::Log4perl->init(\ << ';');
log4perl.rootLogger = DEBUG, string

log4perl.appender.string = Log::Log4perl::Appender::String
log4perl.appender.string.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.string.ConversionPattern = %m%n
;


sub source
{
    my ($source) = @_;

    Filter::Log4perl::_filter($source);
    eval $source;
    die $@ if $@;

    my $appender = Log::Log4perl->appender_by_name('string');

    my $ret = $appender->string;
    $appender->string('');

    return $ret;
}


1;
