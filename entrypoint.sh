#!/bin/sh
usage(){
cat<<USAGE

Usage:
  docker run --rm base16-builder-go

Flags:
  -h, --help            help for build
      --ignore-errors   Don't exit on error if possible to continue

Global Flags:
      --schemes-dir string     Target directory for scheme data (default "./schemes/")
      --sources-dir string     Target directory for source repos (default "./sources/")
      --templates-dir string   Target directory for template data (default "./templates/")
      --verbose                Log all debug messages
USAGE
}

_vars(){
    scheme="${1:-}"
    template="${2:-}"
    extension="${scheme##*.}"
    template_file="$(basename "${template}")"
    scheme_path="/scheme/in.${extension}"
    template_path="/template/${template_file}"
}

hint_main(){
    _vars "${@}"
    cat<<HINT
docker run \\
       --rm \\
       --interactive \\
       --tty \\
       --volume "${scheme}:${scheme_path}" \\
       --volume "${template}:${template_path}" \\
       base16-builder-go
HINT
}

hint_shell(){
    _vars "${@}"
    cat<<HINT
docker run \\
       --rm \\
       --interactive \\
       --tty \\
       --volume "${scheme}:/scheme/in.${extension}" \\
       --volume "${template}:/template/${template_file}" \\
       --entrypoint ash \\
       base16-builder-go
HINT
}

build(){
    if test "$(find /scheme/ /template/ | wc -l)" -gt 3; then
        if base16-builder-go build >/tmp/base16-builder-go.log 2>&1; then
            cat templates/in/output/base16-in.txt
            return 0
        else
            (
                cat /tmp/base16-builder-go.log
                find s[co]* te*
            ) >&2
            return 1
        fi
    else
        (
            printf '\n''[FATAL] Missing either scheme or template file''\n\n''Found:''\n'
            find /scheme/ /template/ | sed 's/^/      /'
        ) >&2
        return 1
    fi
}

case "${1:-}" in
    '')
        build || usage
        ;;
    ash | /bin/ash )
        /bin/ash
        exit $?
        ;;
    shell | sh | bash | dash )
        shift
        hint_shell "${@}"
        ;;
    main )
        shift
        hint_main "${@}"
        ;;
    usage | help | h | -h | -help | --help )
        usage
        ;;
    build | hint_main | hint_shell )
        "${@}"
        ;;
    * )
        if [ "${#}" -eq 2 ]; then
            hint_main "${@}"
        elif test "$(find /scheme/ /template/ | wc -l)" -gt 3; then
            build
        else
            usage
        fi
        ;;
esac
