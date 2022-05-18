=encoding utf8

=head1 NAME

App::Muletracks::Tagger - Rename a file based on its tags

=head1 SYNOPSIS


=cut

use utf8::all;
use Modern::Perl 2018;

use Object::Pad;

# ABSTRACT: Rename a file based on its tags
class App::Muletracks::Tagger {
    use IPC::Run3;
    use List::Util qw(pairmap);
    use Path::Tiny;
    use Text::sprintfn;

    has $format :reader;

    BUILD ($format_) {
        $format = $format_;
    }

    sub get_tags {
        my $file = shift;
        run3 ['metaflac', '--export-tags-to=-', $file], \undef, \my $out;
        # Lowercase key and replace / by - everywhere
        my %tags = pairmap { (lc($a), ($b =~ s!/!-!gr)) }
            map { split /=/ } grep { /^[A-Z]+=/ }
            split /\n/, $out;
        {
            artist => $tags{artist},
            album  => $tags{album},
            track  => $tags{tracknumber},
            title  => $tags{title},
            year   => $tags{date},
            cd     => $tags{discnumber} // 1,
        }
    }

    method apply ($file, %opts) {
        my $dry_run = $opts{dry_run} // 0;
        $file = path($file);
        die "cannot rename non-existent file: $file"
            if not $file->is_file;

        my $name = sprintfn($format, get_tags($file));
        my ($ext) = $file->basename =~ /\.([^.]*)$/;
        my $to = $file->sibling("$name.$ext");
        die "destination already exists: $to"
            if $to->exists;

        if (not $dry_run) {
            $to->parent->mkpath;
            $file->move($to);
        }
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
