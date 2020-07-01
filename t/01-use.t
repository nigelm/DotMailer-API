use strict;
use Test::More;

# see if each of these can be loaded
foreach my $module (
    qw [
    DotMailer::API
    ]
) {
    use_ok($module);
}

done_testing;
