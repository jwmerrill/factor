USING: help.markup help.syntax io strings ;
IN: tools.vocabs.browser

ARTICLE: "vocab-tags" "Vocabulary tags"
{ $all-tags } ;

ARTICLE: "vocab-authors" "Vocabulary authors"
{ $all-authors } ;

ARTICLE: "vocab-index" "Vocabulary index"
{ $subsection "vocab-tags" }
{ $subsection "vocab-authors" }
{ $describe-vocab "" } ;

HELP: words.
{ $values { "vocab" "a vocabulary name" } }
{ $description "Printings a listing of all the words in a vocabulary, categorized by type." } ;
