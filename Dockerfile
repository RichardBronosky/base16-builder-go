FROM golang:alpine AS builder
RUN go get github.com/belak/base16-builder-go

FROM alpine:latest
MAINTAINER Bruno Bronosky bruno@bronosky.com
COPY --from=builder /go/bin/base16-builder-go /usr/local/bin
WORKDIR /

RUN mkdir -p /sources/schemes /sources/templates /templates/in/templates /templates/in/output /schemes/in && \
    printf "in: https://github.com/chriskempson/base16""\n" \
    | tee /sources/schemes/list.yaml \
    | tee /sources/templates/list.yaml && \
    printf "%s\n%s\n%s\n" \
        "default:" \
        "  extension: .txt" \
        "  output: output" \
    | tee /templates/in/templates/config.yaml && \
    ln -s /templates/in/templates /template && \
    ln -s /schemes/in /scheme

COPY Dockerfile /Dockerfile
RUN eval "$( \
        < Dockerfile \
        sed \
        -E \
        ' \
          /[#]extract_entrypoint/!d \
          s/^[# ]+// \
        ' \
    )"

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

####_BEGIN_ENTRYPOINT_####
# #!/bin/sh
# usage(){
# cat<<'USAGE'
# 
# Usage:
#   docker run --rm base16-builder-go [help]
#   eval "$(docker run --rm base16-builder-go scheme.yaml template)"
#   eval "$(docker run --rm base16-builder-go shell scheme.yaml template)"
#   docker run --rm -it base16-builder-go ash
# USAGE
# }
# 
# _vars(){
#     scheme="$(relpath "${1:-}")"
#     template="$(relpath "${2:-}")"
#     #scheme_extension="${scheme##*.}"
#     #scheme_file="in.${scheme_extension}"
#     scheme_file="in.yaml"
#     #template_extension="${template##*.}"
#     #template_file="default.${template_extension}"
#     template_file="default.mustache"
#     scheme_path="/scheme/${scheme_file}"
#     template_path="/template/${template_file}"
# }
# 
# relpath(){
#     rel="$1"
#     # shellcheck disable=SC2088
#     case "$rel" in
#         '/'* )
#             echo "$rel"
#             ;;
#         * )
#             echo "\$PWD/$rel"
#             ;;
#     esac
# }
# 
# hint_main(){
#     _vars "${@}"
#     cat<<HINT
# docker run \\
#        --rm \\
#        --interactive \\
#        --tty \\
#        --volume "${scheme}:${scheme_path}" \\
#        --volume "${template}:${template_path}" \\
#        base16-builder-go
# HINT
# }
# 
# hint_shell(){
#     _vars "${@}"
#     cat<<HINT
# docker run \\
#        --rm \\
#        --interactive \\
#        --tty \\
#        --volume "${scheme}:${scheme_path}" \\
#        --volume "${template}:${template_path}" \\
#        --entrypoint ash \\
#        base16-builder-go
# HINT
# }
# 
# build(){
#     if test "$(find /scheme/ /template/ | wc -l)" -gt 3; then
#         if base16-builder-go build >/tmp/base16-builder-go.log 2>&1; then
#             cat templates/in/output/base16-in.txt
#             return 0
#         else
#             (
#                 cat /tmp/base16-builder-go.log
#                 find s[co]* te*
#             ) >&2
#             return 1
#         fi
#     else
#         (
#             printf '\n''[FATAL] Missing either scheme or template file''\n\n''Found:''\n'
#             find /scheme/ /template/ | sed 's/^/      /'
#         ) >&2
#         return 1
#     fi
# }
# 
# case "${1:-}" in
#     '')
#         build || usage
#         ;;
#     ash | /bin/ash )
#         /bin/ash
#         exit $?
#         ;;
#     shell | sh | bash | dash )
#         shift
#         hint_shell "${@}"
#         ;;
#     main )
#         shift
#         hint_main "${@}"
#         ;;
#     usage | help | h | -h | -help | --help )
#         usage
#         ;;
#     build | hint_main | hint_shell )
#         "${@}"
#         ;;
#     * )
#         if [ "${#}" -eq 2 ]; then
#             hint_main "${@}"
#         elif test "$(find /scheme/ /template/ | wc -l)" -gt 3; then
#             build
#         else
#             usage
#         fi
#         ;;
# esac
# 
# #     < Dockerfile awk '/[#]###_BEGIN_ENTRYPOINT_####/{p=1;next} /[#]###_END_ENTRYPOINT_####/{p=0} p==1{sub("^..",""); print}' > /usr/local/bin/entrypoint.sh && chmod 755 /usr/local/bin/entrypoint.sh #extract_entrypoint
####_END_ENTRYPOINT_####
