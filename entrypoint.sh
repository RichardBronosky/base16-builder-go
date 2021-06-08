#!/bin/sh
usage(){
cat<<'USAGE'

Usage:
  docker run --rm base16-builder-go [help]
  eval "$(docker run --rm base16-builder-go scheme.yaml template)"
  eval "$(docker run --rm base16-builder-go shell scheme.yaml template)"
  docker run --rm -it base16-builder-go ash
USAGE
}

_vars(){
    scheme="$(relpath "${1:-}")"
    template="$(relpath "${2:-}")"
    #scheme_extension="${scheme##*.}"
    #scheme_file="in.${scheme_extension}"
    scheme_file="in.yaml"
    #template_extension="${template##*.}"
    #template_file="default.${template_extension}"
    template_file="default.mustache"
    scheme_path="/scheme/${scheme_file}"
    template_path="/template/${template_file}"
}

relpath(){
    rel="$1"
    # shellcheck disable=SC2088
    case "$rel" in 
        '/'* )
            echo "$rel"
            ;;
        * )
            echo "\$PWD/$rel"
            ;;
    esac
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
       --volume "${scheme}:${scheme_path}" \\
       --volume "${template}:${template_path}" \\
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
