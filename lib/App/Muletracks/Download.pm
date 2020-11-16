=encoding utf8

=head1 NAME

App::Muletracks::Download - Encapsulates a file download

=head1 SYNOPSIS


=cut

use utf8::all;
use Modern::Perl 2018;

use Object::Pad;

# ABSTRACT: Encapsulates a file download
class App::Muletracks::Download {
    has $url      :reader;
    has $filename :reader;

    has $ua;

    BUILD ($url_, $filename_, $client) {
        $url = $url_;
        $filename = $filename_;
        $ua = $client;
    }

    method save ($dest) {
        use Path::Tiny;

        $dest = path($dest);
        $dest->mkpath;

        my $to = $dest->child($filename);
        $ua->get($url)->result->save_to($to);
        $to
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
