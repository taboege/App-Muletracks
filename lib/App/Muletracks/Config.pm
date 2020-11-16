=encoding utf8

=head1 NAME

App::Muletracks::Config - App::Muletracks config file

=head1 SYNOPSIS


=cut

use utf8::all;
use Modern::Perl 2018;

use Object::Pad;

use YAML::PP;

# ABSTRACT: App::Muletracks config file
class App::Muletracks::Config {
    has $file :reader;
    has $hash :reader;

    has $yaml = YAML::PP->new(preserve => YAML::PP::Common::PRESERVE_ORDER);

    BUILD ($infile) {
        $file = $infile;
        $self->load if $infile;
    }

    method load {
        my $from = shift // $file;
        $file //= $from;
        die 'no source path given' if not $from;
        $hash = $yaml->load_file($from);
        $hash
    }

    method save {
        my $to = shift // $file;
        $file //= $to;
        die 'no destination path given' if not $to;
        $yaml->dump_file($to, $hash);
        $self
    }

    method username {
        $hash->{username}
    }

    method password {
        $hash->{password}
    }

    method destination {
        $hash->{destination}
    }

    method format {
        $hash->{format}
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
