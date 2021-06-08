# base16-builder-go

A simple containerized version of
[base16-builder-go](https://github.com/belak/base16-builder-go).

## Docker Container Usage

```console
    scheme_file='scheme.yaml'
    template_file='template'
    scheme_url='https://github.com/chriskempson/base16-default-schemes/raw/daf67429/ocean.yaml'
    template_url='https://github.com/chriskempson/base16-shell/raw/ced506b6/templates/default.mustache'

    curl -sLo $scheme_file   $scheme_url
    curl -sLo $template_file $template_url

    eval "$(
        docker run \
            --rm \
            richardbronosky/base16-builder-go \
            "$scheme_file" \
            "$template_file"
    )" > base16-shell.sh
```
