#!/usr/bin/env bash

tag=base16-builder-go
f1=~/.local/share/flavours/base16/schemes/default/ocean.yaml
f2=~/.local/share/flavours/base16/templates/vim/templates/default.mustache

build(){
    docker build -t $tag .
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

# in `vim Dockerfile` used via: `:exe "normal G{dGo\<esc>" | r !./tools.sh embed_entrypoint`
$put _ | r !
embed_entrypoint(){
    < entrypoint.sh \
      awk \
        -v del='####_%s_ENTRYPOINT_####\n' \
        '
          BEGIN{printf(del, "BEGIN")}
          {print("#", $0)}
          END{printf(del, "END")}
        '
}

"$@"
