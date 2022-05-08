# App::Muletracks - Downloader for Gov't Mule live recordings

This module began as an automated downloader for your purchases on the
Muletracks website, where Gov't Mule sold their live recordings.
That site does not exist anymore and the recordings are now sold via
https://nugs.net.

Adapted to the new platform (but keeping its old name), this project now
works as a general downloader for nugs.net, but its capabilities are very
limited (pagination on your library is not implemented, for instance).

Let me make it clear that this program merely automates clicks on
"Download" buttons that a human would otherwise perform in a browser.
You can only download from nugs.net what you purchased before.

## The trouble of using it

I lack the time to write a neat front-end executable for this module.
So below are the things I do when I need to download something.

First, the configuration file in `$HOME/.config/muletracks/config.yml`:

``` yaml
---
username: "???"
password: "???"
format: "%(artist)s - %(album)s [MuleTracks]/(CD%(cd)1d) %(track)02d. %(title)s"
destination: "$HOME/muletracks"
...
```

Notice the `format` key which instructs the `Tagger` about how to rename the
downloaded files from their embedded tags. I usually buy FLAC files and the
tags I get from muletracks/nugs.net are always absolutely flawless.

To download all your downloadable purchases:

``` perl
use Modern::Perl;
use App::Muletracks;

my @stash = muletracks->login->stash(only => 'avail');
for my $show (@stash) {
    for my $dl ($show->downloads) {
        say $dl->save(muletracks->config->destination);
    }
}
```

To tag all files in the destination folder:

``` perl
use Modern::Perl;
use App::Muletracks;
use App::Muletracks::Tagger;
use Path::Tiny;

my $config = muletracks->config;
my $tagger = App::Muletracks::Tagger->new($config->format);
for (grep { $_->is_file } path($config->destination)->children) {
    say $tagger->apply($_, dry_run => 1);
}'
```

`dry_run => 1` only prints the destination file names without renaming the
files. Change the `format` until you are satisfied and remove the `dry_run`.
