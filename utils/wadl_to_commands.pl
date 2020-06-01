#!/usr/bin/env perl
#
#
use strict;
use warnings;
#
use Path::Tiny;
use XML::Fast;
use Data::Dump qw(dump);

# ------------------------------------------------------------------------
sub process_command_hash {
    my $pathstr = shift;
    my $hash    = shift;

    my $cmd = {};
    $cmd->{name}        = $hash->{-id};
    $cmd->{method}      = $hash->{-name};
    $cmd->{description} = $hash->{'wadl:doc'}{'wadl:summary'};

    # process path
    my ( $path, $args ) = split( /\?/, $pathstr, 2 );
    $path =~ s/\{([a-zA-Z0-9]+)\}/:$1/g;
    $cmd->{path} = $path;
    if ($args) {
        my @queries;
        my @args = split( /\&/, $args );
        foreach my $arg (@args) {
            if ( $arg =~ /^([^=]+)=/ ) {
                my $thing = $1;
                $thing =~ tr/A-Za-z0-9//cd;
                push @queries, $thing;
            }
        }
        $cmd->{query_params} = \@queries;
    }

    return $cmd;
}

# ------------------------------------------------------------------------
sub process_wadl_data {
    my $hash = shift;

    my $resources = $hash->{'wadl:application'}{'wadl:resources'};
    my $base      = $resources->{-base};
    my $commands  = {};
    foreach my $thing ( @{ $resources->{'wadl:resource'} } ) {
        my $path   = $thing->{-path};
        my $method = $thing->{'wadl:method'};
        if ( ref($method) eq 'HASH' ) {
            my $cmd = process_command_hash( $path, $method );
            $commands->{ $cmd->{name} } = $cmd;
        }
        elsif ( ref($method) eq 'ARRAY' ) {
            foreach my $c_hash ( @{$method} ) {
                my $cmd = process_command_hash( $path, $c_hash );
                $commands->{ $cmd->{name} } = $cmd;
            }
        }
        else {
            warn "Confused!\n";
        }
    }
    return $commands;
}

# ------------------------------------------------------------------------
my $inputfile = shift;
my $path      = path($inputfile);
my $xml       = $path->slurp_utf8;
my $hash      = xml2hash $xml;
my $commands  = process_wadl_data($hash);
print dump($commands),"\n";

    # end
