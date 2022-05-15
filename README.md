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

## How to use it

To install this module, you should clone the git repository and run

``` console
$ dzil build && cpanm App-Muletracks*.tar.gz
```

For that, you need the Perl authoring tool `Dist::Zilla` and its
dependencies as well as the `cpanm` package manager. Sorry for the
trouble.

Next, write the configuration file in `$HOME/.config/muletracks/config.yml`:

``` yaml
---
username: "???"
password: "???"
format: "%(artist)s - %(album)s/(CD%(cd)1d) %(track)02d. %(title)s"
destination: "$HOME/muletracks"
...
```

`username` and `password` are your cleartext credentials for nugs.net.

The `format` key which instructs the `Tagger` about how to rename the
downloaded files from their embedded tags. I usually buy FLAC files and the
tags I get from muletracks/nugs.net are always absolutely flawless.

The `destination` is where files are downloaded to. The `Tagger` takes
files from there and renames them according to `format` to someplace
below of the `destination`.

The main executable is `muletracks`. If you run it, it opens an interactive
prompt. Supported commands are:

- `login`: explicitly try to log in. You may give username and password
  as arguments. Otherwise the configuration file is consulted and if
  that also fails, you are prompted for the credentials. All commands
  which require you to be logged in will call this command implicitly.

- `list`: lists all the available shows in your library with media ID,
  artist and title.

- `download`: downloads the given media IDs provided that they are
  available (non-expired) in your library. Each file is downloaded
  and immediately renamed by the `Tagger` (to avoid this, pass the
  `--dry-tag` option). With `--cmus-add`, all new files are added
  via `cmus-remote -l` to your `cmus` library.

- `fetch`: like `download` but does not run the `Tagger`.

- `tag`: takes all files in the `destination` folder (only immediate
  children) and renames them according to their tags and the `format`.
  Supports the `--dry-run` option to just print the destination
  filename without renaming the source file.

# AUTHOR

Tobias Boege <tobs@taboege.de>

# COPYRIGHT AND LICENSE

This software is copyright (C) 2022 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.
