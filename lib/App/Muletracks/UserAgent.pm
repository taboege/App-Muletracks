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

    method login ($username, $password, $url = q[https://www.nugs.net/login/]) {
        my $page = $ua->get($url)->result->dom;
        my $form = $page->at('#dwfrm_login');

        my $target = $form->attr('action');
        my %data = $form->find('input, button')->map(sub {
            my ($name, $value) = $_->attr->@{'name', 'value'};
            $value = $name =~ /username/ ? $username :
                     $name =~ /password/ ? $password :
                     $value;
            ($name, $value)
        })->each;

        my $res = $ua->post($target => form => \%data)->result;
        die 'nugs login failed'
            if defined $res->dom->at('#dwfrm_login *.error-form');
        $self
    }

    method logout {
        $ua->get(q[https://www.nugs.net/on/demandware.store/Sites-NugsNet-Site/default/Login-Logout])
            ->result->body;
    }

    sub DESTROY {
        shift->logout;
    }

    method stash ($only = 'avail') {
        my $url = q[https://www.nugs.net/on/demandware.store/Sites-NugsNet-Site/default/Stash-Load?format=ajax];
        my %fake_headers = (
            'Referer' => q[https://www.nugs.net/stash/],
            'X-Requested-With' => q[XMLHttpRequest],
        );
        my $page = $ua->post($url, \%fake_headers)->result->dom;
        my @stash;
        for my $show ($page->find('.showData')->each) {
            my $st = App::Muletracks::Stashed->new($show, $ua);
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
