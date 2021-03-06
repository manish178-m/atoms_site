#!/bin/bash

#this is exactly equal to "pre_process_dl.sh" but with download commented out
# To Do : unify both files and conditionally download according to some cli arg flag

mkdir -p proc

#---------------------------------------------------------------------------------------------------
# people
#---------------------------------------------------------------------------------------------------
if [ $# == "0" ] || [ $1 == "people" ]; then
#  address="http://servicosweb.cnpq.br/wspessoa/servletrecuperafoto?tipo=1&id="
#  for code in $(grep 'lattes-K[0-9]\{7\}[A-Z][0-9]' pages/people.md | cut -d "-" -f2); do
#    image="images/$code.jpg"
#    options="--retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue"
    #removed --continue because of weird behavior - file size increased bud renderend picture was the same as before
#    for i in $(seq 1 20); do
#      echo "wget $options -O $image \"$address$code\""
#      eval "wget $options -O $image \"$address$code\""
#      if [ $? = 0 ]; then break; fi; # check return value, break if successful (0)
#      sleep 1s;
#    done;
#    width=$(identify -format "%w" $image)
#    if [ "$width" -gt "200" ]; then
#      percent=$(echo "20000/$width" | bc)
#      eval "convert -resize $percent% $image $image"
#    fi
#  done
  before="<table id=\"gradient-style-large\"><tr><th><\/th><th><h2>"
  after="<\/h2><\/th><\/tr><tr><td><\/td><td>"
  code="K[0-9]{7}[A-Z][0-9]"
  link="http:\/\/buscatextual.cnpq.br\/buscatextual\/visualizacv.do?id="
  attr="target=\"_blank\" title=\"Curriculum vitae\""
  pre="\@htmlonly\n<\/td><\/tr><tr><td>"
  post="<\/td><td>\n\@endhtmlonly"
  sed -r -e "s/\@header:(.*)/$before\1$after/g" \
    -e "s/\@endheader/<\/td><\/tr><\/table>\n<hr>\n/g" \
    -e "s/(Ksemfoto)/$pre<a href=\"$link\1\" $attr><img src=\"..\/images\/Ksemfoto.jpg\"><\/a>$post/g" \
    -e "s/lattes-($code)/$pre<a href=\"$link\1\" $attr><img src=\"..\/images\/\1.jpg\"><\/a>$post/g" \
  pages/people.md > proc/people.md
fi




#---------------------------------------------------------------------------------------------------
# publications
#---------------------------------------------------------------------------------------------------
if [ $# == "0" ] || [ $1 == "publications" ]; then
  
  
  #iuri version for crating a temp file with new publications for fixes and periodic emptying of the markdown file
  
  function proc_new_publications() {
    regex="DOI:\ ([^\ ]*)"
    #gets each doi from pages/publications.md
    for doi in $(egrep "$regex" pages/publications.md | sed -r "s/$regex/\1/g"); do
      tools/doi2bib.sh $doi
    done
  }
  
  #runs proc_publications and redirects echos/cat to file proc/publications.md
  proc_new_publications > pages/new_publications.bib
  

  #modified old function
function proc_publications() {
    echo -e "Publications {#publications}\n============\n"
    echo "@htmlonly"
    echo "<table id=\"pubTable\" class=\"display\"></table>"
    echo "<pre id=\"bibtex\">"
    regex="DOI:\ ([^\ ]*)"
    #gets each doi from pages/publications.md
#    for doi in $(egrep "$regex" pages/publications.md | sed -r "s/$regex/\1/g"); do
#      tools/doi2bib.sh $doi
#    done
    cat pages/new_publications.bib
    cat pages/publications.bib
    echo "</pre>"
    echo "<script type=\"text/javascript\" src=\"bib-list.js\"></script>"
    echo "<script type=\"text/javascript\">"
    echo "  (document).ready(function() {"
    echo "    bibtexify(\"#bibtex\", \"pubTable\");"
    echo "  });"
    echo "</script>"
    echo "@endhtmlonly"
  }
  
  #runs proc_publications and redirects echos/cat to file proc/publications.md
  proc_publications > proc/publications.md
  #in summary: merges content from the formated pages/publications.bib
  # together with automatic content from pages/publications.md via doi2bib
  # putting into the html tagged md proc/publications.md for doxygen


fi

