=encoding utf8

=head1 NAME

App::Muletracks::Stashed - A purchased item from your stash

=head1 SYNOPSIS


=cut

use utf8::all;
use Modern::Perl 2018;

use Object::Pad;

use App::Muletracks::Download;

# ABSTRACT: A purchased item from your stash
class App::Muletracks::Stashed {
    has $media_id  :reader;
    has $user_id   :reader;

    has $artist    :reader;
    has $title     :reader;
    has $format    :reader;
    has $available :reader;

    has $ua;

    BUILD ($show, $client) {
        $ua = $client;

        $artist = $show->at('h5')->text;
        $title  = $show->at('.showtitle-st')->text;
        $format = $show->at('.format > span')->text;

        my $link   = $show->following->first->at('a');
        $available = $link->attr('data-stash-downloadable') // 'false';
        $available = $available eq 'true';

        $media_id  = $link->attr('data-stash-album');
        $user_id   = $link->attr('data-stash-album-user-id');
    }

    method download {
        use Mojo::JSON qw(decode_json);

        return () unless $available and
            defined($media_id) and
            defined($user_id);

        # First obtain the service URL
        my $url = qq[https://www.nugs.net/on/demandware.store/Sites-NugsNet-Site/default/Stash-Download?ids=${media_id}&userID=${user_id}];
        my %fake_headers = (
            'Referer' => q[https://www.nugs.net/stash/],
            'X-Requested-With' => q[XMLHttpRequest],
        );
        my $json = $ua->get($url, \%fake_headers)->result->json;
        $url = $json->{data}{serviceURL};
        delete %fake_headers{'X-Requested-With'};

        # Now we can list all the tracks and make Downloads for them
        my @downloads;
        my $data = $ua->get($url, \%fake_headers)->result->body;
        $json = decode_json($data =~ m/\{.+\}/g);
        for my $track ($json->{items}->@*) {
            my ($url, $filename) = $track->@{'url', 'filename'};
            # XXX: We're trusting the server's filename
            push @downloads, App::Muletracks::Download($url => $filename, $ua);
        }
        @downloads
    }
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
