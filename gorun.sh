#!/bin/bash

cmd_list() {
    go list "${flags[@]}" -f '{{range .GoFiles}}{{$.Dir}}/{{.}}{{"\n"}}{{end}}' "$pkg"
    return $?
}

cmd_usage() {
    cat >&2 <<EOD
usage: $(basename "$0") [-l] [-tags tags] packages
EOD
    exit 2
}

while [[ "$1" == -* ]]; do
    if [ "$1" = '-l' ]; then
        mode_list=1; shift
    elif [ "$1" = '-tags' ]; then
        flags=(-tags "$2")
        shift 2
    else
        cmd_usage
    fi
done

pkg="$1"; shift || cmd_usage
if [ -n "$mode_list" ]; then
    cmd_list
    exit $?
fi

files=($(cmd_list)) || exit $?
go run "${flags[@]}" -exec "bash -c 'shift; exec \"\$0\" \"\$@\"'" "${files[@]}" -- "$@"
