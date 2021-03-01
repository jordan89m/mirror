#!/bin/bash

tmpdir=$(mktemp -d)
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

while read -r config; do
  IFS="," read -r -a fields <<<"$config"
  url="${fields[0]}"
  fields=("${fields[@]:1}")
  for repo in "${fields[@]}"; do
    if [ -L "mirror/$repo" ] || [ -L "mirror/$repo/aarch64" ]; then
      continue
    fi
    mkdir -p "mirror/$repo/aarch64"
    wget "${url//\$repo/$repo}/$repo.db" -O "mirror/$repo/aarch64/$repo.db"

    cp "mirror/$repo/aarch64/$repo.db" "$tmpdir/$repo.db"
    mkdir -p "$tmpdir/$repo"
    tar -xf "$tmpdir/$repo.db" -C "$tmpdir/$repo"
    filenames=()
    for pkgfile in "$tmpdir/$repo"/*/desc; do
      readarray -t lines <"$pkgfile"
      filename=""
      sha256sum=""
      for i in "${!lines[@]}"; do
        line="${lines[$i]}"
        if [ "$line" == "%FILENAME%" ]; then
          filename="${lines[$i + 1]}"
        elif [ "$line" == "%SHA256SUM%" ]; then
          sha256sum="${lines[$i + 1]}"
        fi
        if [ -n "$filename" ] && [ -n "$sha256sum" ]; then
          break
        fi
      done
      filenames+=("$filename")
      if [ -f "mirror/$repo/aarch64/$filename" ] && [ "$(sha256sum "mirror/$repo/aarch64/$filename")" != "$sha256sum  mirror/$repo/aarch64/$filename" ]; then
        echo "Invalid checksum, deleting old file"
        rm "mirror/$repo/aarch64/$filename"
      fi
      while [ ! -f "mirror/$repo/aarch64/$filename" ]; do
        wget "${url//\$repo/$repo}/$filename" -O "mirror/$repo/aarch64/$filename"
        if [ "$(sha256sum "mirror/$repo/aarch64/$filename")" != "$sha256sum  mirror/$repo/aarch64/$filename" ]; then
          echo "Invalid checksum, retrying"
          rm "mirror/$repo/aarch64/$filename"
        fi
      done
    done
    for file in "mirror/$repo/aarch64/"*; do
      if [ "$(basename "$file")" == "$repo.db" ]; then
        continue
      fi
      if ! [[ ${filenames[*]} =~ (^|[[:space:]])"$(basename "$file")"($|[[:space:]]) ]]; then
        echo "Deleting old file $file"
        rm "$file"
      fi
    done
  done
done <repos
