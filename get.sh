#!/bin/bash
basedir=$(pwd)
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
    if [ -f "mirror/$repo/aarch64/repo.txt" ]; then
      rm "mirror/$repo/aarch64/repo.txt"
    fi
    filenames=()
    for pkgfile in "$tmpdir/$repo"/*/desc; do
      readarray -t lines <"$pkgfile"
      filename=""
      sha256sum=""
      for i in "${!lines[@]}"; do
        line="${lines[$i]}"
        if [ "$line" == "%FILENAME%" ]; then
          filename="${lines[$i + 1]}"
          echo "${url//\$repo/$repo}/$filename" >> mirror/$repo/aarch64/repo.txt
        fi
      done
     done
     aria2c -s 16 -x 16 -j 16 -c -i "mirror/$repo/aarch64/repo.txt" -d "mirror/$repo/aarch64/"
  done
done <repos
