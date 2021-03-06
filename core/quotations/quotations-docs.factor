USING: arrays help.markup help.syntax strings sbufs
vectors kernel combinators ;
IN: quotations

ARTICLE: "quotations" "Quotations"
"Conceptually, a quotation is an anonymous function (a value denoting a snippet of code) which can be passed around and called."
$nl
"Concretely, a quotation is an immutable sequence of objects, some of which may be words, together with a block of machine code which may be executed to achieve the effect of evaluating the quotation. The machine code is generated by a fast non-optimizing quotation compiler which is always running and is transparent to the developer."
$nl
"Quotations form a class of objects, however in most cases, methods should dispatch on " { $link callable } " instead, so that " { $link curry } " and " { $link compose } " values can participate."
{ $subsection quotation }
{ $subsection quotation? }
"Quotations evaluate sequentially from beginning to end. Literals are pushed on the stack and words are executed. Details can be found in " { $link "evaluator" } "."
$nl
"Quotation literal syntax is documented in " { $link "syntax-quots" } "."
$nl
"Quotations implement the " { $link "sequence-protocol" } ", and existing sequences can be converted into quotations:"
{ $subsection >quotation }
{ $subsection 1quotation }
"Wrappers:"
{ $subsection "wrappers" } ;

ARTICLE: "wrappers" "Wrappers"
"Wrappers are used to push words on the data stack; they evaluate to the object being wrapped:"
{ $subsection wrapper }
{ $subsection literalize }
{ $see-also "dataflow" "combinators" } ;

ABOUT: "quotations"

HELP: callable
{ $class-description "The class whose instances can be passed to " { $link call } ". This includes quotations and composed quotations built up with " { $link curry } " or " { $link compose } "." } ;

HELP: quotation
{ $description "The class of quotations. See " { $link "syntax-quots" } " for syntax and " { $link "quotations" } " for general information." } ;

HELP: >quotation
{ $values { "seq" "a sequence" } { "quot" quotation } }
{ $description "Outputs a freshly-allocated quotation with the same elements as a given sequence." } ;

HELP: 1quotation
{ $values { "obj" object } { "quot" quotation } }
{ $description "Constructs a quotation holding one element." }
{ $notes
    "The following two phrases are equivalent:"
    { $code "\\ reverse execute" }
    { $code "\\ reverse 1quotation call" }
} ;

HELP: wrapper
{ $description "The class of wrappers. Wrappers are created by calling " { $link literalize } ". See " { $link "syntax-words" } " for syntax." } ;

HELP: <wrapper> ( obj -- wrapper )
{ $values { "obj" object } { "wrapper" wrapper } }
{ $description "Creates an object which pushes " { $snippet "obj" } " on the stack when evaluated. User code should call " { $link literalize } " instead, since it avoids wrapping self-evaluating objects (which is redundant)." } ;

HELP: literalize
{ $values { "obj" object } { "wrapped" object } }
{ $description "Outputs an object which evaluates to " { $snippet "obj" } " when placed in a quotation. If " { $snippet "obj" } " is not self-evaluating (for example, it is a word), then it will be wrapped." }
{ $examples
    { $example "USING: prettyprint quotations ;" "5 literalize ." "5" }
    { $example "USING: math prettyprint quotations sequences ;" "[ + ] [ literalize ] map ." "[ \\ + ]" }
} ;

{ literalize curry <wrapper> POSTPONE: \ POSTPONE: W{ } related-words
