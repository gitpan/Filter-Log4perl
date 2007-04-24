package Filter::Log4perl;

use 5.008001;
use strict;
use warnings;
use version;

use Filter::Simple;


our $VERSION = '0.00_02';
$VERSION = qv($VERSION);


# The method _filter() is used in test cases.
# See also t::MyTest.
FILTER { _filter($_) };


sub _filter
{
    use PPI;

    my $doc = PPI::Document->new(\$_[0]);
    return if ! $doc;

    my $comments = $doc->find('PPI::Token::Comment');
    return if ! $comments;

    foreach my $comment (@$comments) {
        __PACKAGE__->_filter_comment($comment);
    }

    $_[0] = $doc->serialize;
#    print STDERR $_[0];
}


use Regexp::Common qw/balanced/;

our $_var_re = qr/
    [\$\%\@]
    (?:
        # $var
        [[:alpha:]_][[:alnum:]_]*
    |
        # ${$var}
        $RE{balanced}{-parens=>'{}'}
    |
        # $@var
        (??{ $Filter::Log4perl::_var_re })
    )
    (?:
        # $var{...}, $var[...], $var->{...}, $var->[...]
        (?:
            \-\>
        )
        $RE{balanced}{-parens=>'{}[]'}
    )?
/x;


sub _filter_comment
{
    use Data::Dump qw/dump/;

    my ($proto, $comment) = @_;
    my $content = $comment->{content};

    if ($content !~ s/^\s*#+\s*<(debug|info|warn|error|fatal)>\s*//) {
        return;
    }
    my $log_level = $1;

    my $format = '';
    my @vars = ();

    while ($content) {
        if ($content =~ s/\\(.)//) {
            $format .= $1 eq '%' ? '%%' : $1;
        }
        elsif ($content =~ s/^%%//) {
            $format .= '%%';
        }
        elsif ($content =~ s/^([^\$\@\%]+)//) {
            $format .= $1;
        }
        elsif ($content =~ s/^($_var_re)//) {
            $format .= '%s';
            push(@vars, $1);
        }
        else {
            $content =~ s/^(.)//;

            $format .= $1 eq '%' ? '%%' : $1;
        }
    }

    my $code
        = sprintf 'Filter::Log4perl->log(%s, %s);',
          dump($log_level),
          join(
              ', ',
              dump($format),
              map {
                  "[ $_ ]"
              } @vars
          )
    ;

    # WORKAROUND: PPI::Element->replace() is not implemeted.
    $comment->{content} = $code;
#    print STDERR "$code\n";
}


sub log
{
    use Log::Log4perl;

    my ($proto, $log_level, $format, @vars) = @_;

    Log::Log4perl->get_logger(scalar caller())->$log_level(
        sprintf $format, map { dump(@$_) } @vars
    );
}


1;
__END__

=head1 NAME

Filter::Log4perl - no extra codes logging (same as Log::Log4perl qw/:resurrect/)

=head1 SYNOPSIS

    # enables
    use Filter::Log4perl;

    my $var = undef;
    # <debug> $var

    $var = suspect_value();
    # <debug> after: $var

    # <info> Now computing value...
    for my $i (1 .. 100) {
        # <debug> data $i: $var->[$i] <file>
    }

    # disables
    no Filter::Log4perl;

=head1 DESCRIPTION

This module provides Log::Log4perl (L::L4P) loggings from comments
same feature as L::L4P resurrection, but more smart.

=head1 SYNTAX

# <LEVEL> MESSAGE

=head2 LEVEL

=over 4

=over 4

=item * debug

=item * info

=item * warn

=item * error

=item * fatal

=back

=back

=head2 MESSAGE

A string.

Variable notations ($var/@var/%var...) are expanded by Data::Dump dump().

    Input:

        my @var = qw/a b c/;
        # <debug> var: @var

    Output:

        var: ("a", "b", "c")

=head1 CONFIGURATION AND ENVIRONMENT

This module doesn't call Log::Log4perl::init() and elsewhere.

You must call these before loggings.

=head1 SEE ALSO

=over 4

=item * Log::Log4perl

=item * Smart::Comments

=item * Filter::Simple

=back

=head1 AUTHOR

FUJIMURA Yuki E<lt>L<fujimura@cpan.org>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by FUJIMURA Yuki

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
