# mirror

An Artix ARM fork of a script by @jld3103.

Prerequisites: aria2

Simply run get.sh and aria2 will handle bulk downloads efficiently. Should any URLs return an error at the end of the download, re-run the script to collect any absent files.

Currently this version does not handle checksums. Two reasons: A) Still learning stuff. B) My day-job's industry has been rocked by the pandemic and my free time is currently extremely limited.

Tested on a 1000Mbps connection (roughly 140MB/s download capacity) and downloaded all required files in about 5-6 minutes.

Original description below.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
A tool to create a local mirror for https://github.com/arch-beryllium/build

## Usage

```bash
./update.sh
```

This tool doesn't use parallel downloads, because some mirrors seem to dislike it, but once you mirrored everything,
updating it should be fast.

## Serving the mirror

Use the `serve.sh` script to host the mirror on `http://localhost:8080`.  
Then put `http://your.ip.address:8080/$repo/$arch` as your server URL in the pacman config.

## Migrating from https://github.com/arch-beryllium/arch-repo-mirror

You can simply copy the mirror folder from that repo to this, and it will just work.
