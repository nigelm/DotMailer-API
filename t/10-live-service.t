use strict;
use Test::More;
use Test::Exception;

use DotMailer::API;

my $username = 'demo@apiconnector.com';
my $password = 'demo';

subtest 'Connection test with correct parameters' => sub {

    my $api = new_ok 'DotMailer::API' => [
        username => $username,
        password => $password,
    ];
    isa_ok( $api, 'DotMailer::API', 'Correct return type' );

    my $res = $api->GetAccountInfo;
    is( $res->{code}, '200', 'Got expected status' );
    ok( ( $res->{content}->{id} > 0 ), 'Valid id returned' );
    is( ref( $res->{content}{properties} ), 'ARRAY', 'Array of properties returned' );

    done_testing();
};

done_testing();

# end
