=encoding utf8

=head1 NAME

App::Muletracks::UserAgent - Navigate nugs downloads

=head1 SYNOPSIS


=cut

use utf8::all;
use Modern::Perl 2018;

use Object::Pad;

use Mojo::DOM;
use Mojo::UserAgent;

use App::Muletracks::Stashed;

# ABSTRACT: Navigate nugs downloads
class App::Muletracks::UserAgent {
    has $ua = Mojo::UserAgent->new(max_redirects => 5);
    has $logged_out = 0;

    method login ($username, $password, $url = q[https://www.nugs.net/login/]) {
        my $tx = $ua->get($url);
        my $page = $tx->res->dom;
        my $form = $page->at('form');

        my $target = $form->attr('action') // $tx->req->url;
        my %data = $form->find('input')->map(sub {
            my ($name, $value) = $_->attr->@{'name', 'value'};
            $value = $name =~ /email/i    ? $username :
                     $name =~ /password/i ? $password :
                     $value;
            ($name, $value)
        })->each;

        my $res = $ua->post($target => form => \%data)->result;
        die 'nugs login failed'
            if defined $res->dom->at('.validation-summary-errors');
        $logged_out = 0;
        $self
    }

    method logout {
        $logged_out = $ua->get(q[https://www.nugs.net/on/demandware.store/Sites-NugsNet-Site/default/Login-Logout])
            ->result->is_success;
    }

    method DESTROY {
        $self->logout unless $logged_out;
    }

    method stash ($only = 'avail') {
        my $url = q[https://www.nugs.net/on/demandware.store/Sites-NugsNet-Site/default/Stash-Load?format=ajax];
        my %fake_headers = (
            'Referer' => q[https://www.nugs.net/stash/],
            'X-Requested-With' => q[XMLHttpRequest],
        );
        my %form = (selectedSorting => 'purchaseDateDesc'); # newest first
        my $page = $ua->post($url, \%fake_headers, form => \%form)->result->dom;
        my @stash;
        for my $album ($page->find('.album')->each) {
            my $st = App::Muletracks::Stashed->new($album, $ua);
            push @stash, $st if $only eq 'all' or
                ($only eq 'avail' and $st->available);
        }
        @stash
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
