! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel sequences vectors ;
IN: sets

: (prune) ( elt hash vec -- )
    3dup drop key?
    [ [ drop dupd set-at ] [ nip push ] [ ] 3tri ] unless
    3drop ; inline

: prune ( seq -- newseq )
    [ ] [ length <hashtable> ] [ length <vector> ] tri
    [ [ (prune) ] 2curry each ] keep ;

: unique ( seq -- assoc )
    [ dup ] H{ } map>assoc ;

: (all-unique?) ( elt hash -- ? )
    2dup key? [ 2drop f ] [ dupd set-at t ] if ;

: all-unique? ( seq -- ? )
    dup length <hashtable> [ (all-unique?) ] curry all? ;

: intersect ( seq1 seq2 -- newseq )
    unique [ key? ] curry subset ;

: diff ( seq1 seq2 -- newseq )
    swap unique [ key? not ] curry subset ;

: union ( seq1 seq2 -- newseq )
    append prune ;