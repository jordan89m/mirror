# mirror

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
