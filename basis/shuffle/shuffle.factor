! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators effects.parser generalizations
hashtables kernel locals locals.backend macros make math
parser sequences ;
IN: shuffle

<PRIVATE

: >index-assoc ( sequence -- assoc )
    dup length zip >hashtable ;

PRIVATE>

MACRO: shuffle-effect ( effect -- )
    [ out>> ] [ in>> >index-assoc ] bi
    [
        [ nip assoc-size , \ narray , ]
        [ [ at \ swap \ nth [ ] 3sequence ] curry map , \ cleave , ] 2bi
    ] [ ] make ;

: shuffle(
    ")" parse-effect parsed \ shuffle-effect parsed ; parsing

: 2swap ( x y z t -- z t x y ) 2 2 mnswap ; inline

: 4dup ( a b c d -- a b c d a b c d ) 4 ndup ; inline

: 4drop ( a b c d -- ) 3drop drop ; inline
