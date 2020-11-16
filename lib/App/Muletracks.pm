=encoding utf8

=head1 NAME

App::Muletracks - Bundle of App::Muletracks::*

=head1 SYNOPSIS


=cut

use utf8::all;
use Modern::Perl 2018;

use Object::Pad;

use App::Muletracks::Config;
use App::Muletracks::UserAgent;

use Path::Tiny;

# ABSTRACT: Bundle of App::Muletracks::*
class App::Muletracks {
    has $config :reader;
    has $ua     :reader;

    BUILD ($config_file) {
        $config = App::Muletracks::Config->new($config_file);
        $ua = App::Muletracks::UserAgent->new;
    }

    method login {
        $ua->login($config->username, $config->password);
        $self
    }

    method stash {
        $ua->stash
    }
}

my sub xdg {
    state $xdg = do {
        # XXX: Silence experimental warnings from File::XDG
        local %SIG;
        $SIG{__WARN__} = sub {
            warn(@_) unless $_[0] =~ /(given|when) is experimental/;
        };
        require File::XDG;
        File::XDG->new(name => 'muletracks');
    }
}

my %MULETRACKS;
sub muletracks {
    my $config_file = shift // path(xdg->config_home, 'config.yml')->touchpath;
    $MULETRACKS{$config_file} //= do {
        my $mt = App::Muletracks->new($config_file);

        # Sanity checking
        for my $key (qw(username password destination format)) {
            die "configuration key '$key' missing in @{[ $mt->config->file ]}"
                unless $mt->config->$key;
        }

        $mt
    }
}

=head1 HISTORY

This module and program are a port of an old Perl 6 project of the same
name which I apparently never published. The old program worked with an
old interface which was presented at C<http://muletracks.com> and used
C<https://secure.livedownloads.com/gmule/> for downloads. This seems to
have been replaced by L<https://nugs.net> since. I decided not to rename
the project, but it seems to be a general Nugs downloader now.

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
