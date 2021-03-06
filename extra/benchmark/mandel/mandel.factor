! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel math math.functions sequences prettyprint
io.files io.files.temp io.encodings io.encodings.ascii
io.encodings.binary fry benchmark.mandel.params
benchmark.mandel.colors ;
IN: benchmark.mandel

: x-inc ( -- x ) width  200000 zoom-fact * / ; inline
: y-inc ( -- y ) height 150000 zoom-fact * / ; inline

: c ( i j -- c )
    [ x-inc * center real-part x-inc width 2 / * - + >float ]
    [ y-inc * center imaginary-part y-inc height 2 / * - + >float ] bi*
    rect> ; inline

: count-iterations ( z max-iterations step-quot test-quot -- #iters )
    '[ drop @ dup @ ] find-last-integer nip ; inline

: pixel ( c -- iterations )
    [ C{ 0.0 0.0 } max-iterations ] dip
    '[ sq _ + ] [ absq 4.0 >= ] count-iterations ; inline

: color ( iterations -- color )
    [ color-map [ length mod ] keep nth ] [ B{ 0 0 0 } ] if* ; inline

: render ( -- )
    height [ width swap '[ _ c pixel color write ] each ] each ; inline

: ppm-header ( -- )
    ascii encode-output
    "P6\n" write width pprint " " write height pprint "\n255\n" write
    binary encode-output ; inline

: mandel-main ( -- )
    "mandel.ppm" temp-file binary [ ppm-header render ] with-file-writer ;

MAIN: mandel-main
