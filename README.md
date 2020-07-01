# NAME

DotMailer::API - Interact with the DotMailer platform API

# VERSION

version 0.001

# SYNOPSIS

    # THIS IS AT AN EARLY STAGE OF DEVELOPMENT - PROTOTYPING REALLY
    # IT MAY CHANGE DRAMATICALLY OR EAT YOUR DATA.

    use DotMailer::API

    my $api = DotMailer::API->new(
        username => 'demo@apiconnector.com',
        password => 'demo',
        debug => 1 );

    my $res = $api->GetAccountInfo;

## Attributes

### api\_url

Base API URL of the service.  Defaults to `https://api.dotmailer.com`. On the
initial connection a `GetAccountInfo` operation is carried out, and the
`ApiEndpoint` is taken from that and replaces the value of `api_url` so that
the correct regional URL is used for the authenticated user.

### username

Username for logging in to the service.  Required.

### password

Password for logging in to the service.  Required.

### debug

Set debug on.  The higher the debug level, the more chatter is exposed.

# DESCRIPTION

[Web::API](https://metacpan.org/pod/Web%3A%3AAPI) based API interface to the DotDigital / DotMailer Engagement Cloud
API - as described at [https://developer.dotdigital.com/docs](https://developer.dotdigital.com/docs).

The lack of documentation reflects the stage in development...

# AUTHOR

Nigel Metheringham <nigelm@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Nigel Metheringham.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
