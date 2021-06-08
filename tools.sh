#!/usr/bin/env bash

tag=base16-builder-go
user=richardbronosky
f1=~/.local/share/flavours/base16/schemes/default/ocean.yaml
f2=~/.local/share/flavours/base16/templates/vim/templates/default.mustache

build(){
    embed_entrypoint
    docker build -t $tag .
}

push(){
    # shellcheck disable=SC2016
    echo 'This function uses `docker push`, but CI/CD would have you `git push`'
    read -r -p 'Ctrl-C to break, or Enter to continue? '
    docker tag  $tag $user/$tag
    docker push      $user/$tag
}

shell(){
    docker run --rm -it --entrypoint ash $tag
}

ex1(){
    docker run --rm -it \
           -v "$f1:/schemes/in/$(basename "$f1")" \
           -v "$f2:/templates/in/templates/$(basename "$f2")" \
           --entrypoint ash
           $tag
}

ex2(){
    docker run --rm -it \
           --entrypoint /usr/local/bin/entrypoint.sh
           $tag \
           $f1 \
           $f2
}

run_tests(){
    scheme_file='scheme.yaml'
    scheme_url='https://github.com/chriskempson/base16-default-schemes/raw/daf67429/ocean.yaml'
    template_file='template'
    template_url='https://github.com/chriskempson/base16-shell/raw/ced506b6/templates/default.mustache'
    relpath="../$(basename "$PWD")"
    curl -sLo $scheme_file   $scheme_url
    curl -sLo $template_file $template_url
    eval "$(
        docker run \
            --rm \
            $tag \
            "$relpath/$scheme_file" \
            "$relpath/$template_file"
    )"
}

# in `vim Dockerfile` used via: `:exe "normal G{dGo\<esc>" | r !./tools.sh embed_entrypoint`
# $put _ | r !./tools.sh embed_entrypoint
embedable_entrypoint(){
    < entrypoint.sh \
      awk \
        -v del='####_%s_ENTRYPOINT_####\n' \
        -v self="$0" \
        '
          BEGIN{printf(del, "BEGIN")}
          {printf("# %s\n", $0)}
          END{
            "grep -E \"[#]extract_entrypoint\" " self | getline;
            printf("# \n# # %s\n", $0)
            printf(del, "END")
          }
        '
}

extract_entrypoint(){
    < Dockerfile awk '/[#]###_BEGIN_ENTRYPOINT_####/{p=1;next} /[#]###_END_ENTRYPOINT_####/{p=0} p==1{sub("^..",""); print}' > /usr/local/bin/entrypoint.sh && chmod 755 /usr/local/bin/entrypoint.sh #extract_entrypoint
}

remove_entrypoint(){
    # shellcheck disable=SC2005
    echo "$( # this seemingly unnecessary echo strips empty lines from the end
      < Dockerfile \
        awk \
          '
          /[#]###_BEGIN_ENTRYPOINT_####/{r=1; next}
          /[#]###_END_ENTRYPOINT_####/{r=0; next}
          r==1{next}
          {print}
          '
    )"
}

embed_entrypoint(){
    dockerfile="$(remove_entrypoint)"
    {
        echo "$dockerfile"
        echo
        embedable_entrypoint
    } >Dockerfile
}

"$@"
