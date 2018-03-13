#!/bin/bash

set -e

while [[ "$1" == -* ]]; do
    if [ "$1" = '-l' ]; then
        mode_list=1; shift
    elif [ "$1" = '-tags' ]; then
        flags=(-tags "$2")
        shift 2
    else
        cat >&2 <<EOD
usage: $(basename "$0") [-l] [-tags tags] packages
EOD
        exit 2
    fi
done

cmd_list() {
    go list "${flags[@]}" -f '{{range .GoFiles}}{{$.Dir}}/{{.}}{{"\n"}}{{end}}' "$pkg"
    return $?
}

pkg="$1"; shift
if [ -n "$mode_list" ]; then
    cmd_list
    exit $?
fi

files=($(cmd_list))
go run "${flags[@]}" -exec "bash -c 'shift; exec \"\$0\" \"\$@\"'" "${files[@]}" -- "$@"
