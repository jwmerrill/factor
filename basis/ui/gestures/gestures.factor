! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math math.order models
namespaces make sequences words strings system hashtables
math.parser math.vectors classes.tuple classes boxes calendar
alarms combinators sets columns fry deques ui.gadgets ;
IN: ui.gestures

GENERIC: handle-gesture ( gesture gadget -- ? )

M: object handle-gesture
    tuck class superclasses
    [ "gestures" word-prop ] map
    assoc-stack dup [ call f ] [ 2drop t ] if ;

: set-gestures ( class hash -- ) "gestures" set-word-prop ;

: gesture-queue ( -- deque ) \ gesture-queue get ;

GENERIC: send-queued-gesture ( request -- )

TUPLE: send-gesture gesture gadget ;

M: send-gesture send-queued-gesture
    [ gesture>> ] [ gadget>> ] bi handle-gesture drop ;

: queue-gesture ( ... class -- )
    boa gesture-queue push-front notify-ui-thread ; inline

: send-gesture ( gesture gadget -- )
    \ send-gesture queue-gesture ;

: each-gesture ( gesture seq -- ) [ send-gesture ] with each ;

TUPLE: propagate-gesture gesture gadget ;

M: propagate-gesture send-queued-gesture
    [ gesture>> ] [ gadget>> ] bi
    [ handle-gesture ] with each-parent drop ;

: propagate-gesture ( gesture gadget -- )
    \ propagate-gesture queue-gesture ;

TUPLE: propagate-key-gesture gesture world ;

: world-focus ( world -- gadget )
    dup focus>> [ world-focus ] [ ] ?if ;

M: propagate-key-gesture send-queued-gesture
    [ gesture>> ] [ world>> world-focus ] bi
    [ handle-gesture ] with each-parent drop ;

: propagate-key-gesture ( gesture world -- )
    \ propagate-key-gesture queue-gesture ;

TUPLE: user-input string world ;

M: user-input send-queued-gesture
    [ string>> ] [ world>> world-focus ] bi
    [ user-input* ] with each-parent drop ;

: user-input ( string world -- )
    '[ _ \ user-input queue-gesture ] unless-empty ;

! Gesture objects
TUPLE: motion ;             C: <motion> motion
TUPLE: drag # ;             C: <drag> drag
TUPLE: button-up mods # ;   C: <button-up> button-up
TUPLE: button-down mods # ; C: <button-down> button-down
TUPLE: mouse-scroll ;       C: <mouse-scroll> mouse-scroll
TUPLE: mouse-enter ;        C: <mouse-enter> mouse-enter
TUPLE: mouse-leave ;        C: <mouse-leave> mouse-leave
TUPLE: lose-focus ;         C: <lose-focus> lose-focus
TUPLE: gain-focus ;         C: <gain-focus> gain-focus

! Higher-level actions
TUPLE: cut-action ;         C: <cut-action> cut-action
TUPLE: copy-action ;        C: <copy-action> copy-action
TUPLE: paste-action ;       C: <paste-action> paste-action
TUPLE: delete-action ;      C: <delete-action> delete-action
TUPLE: select-all-action ;  C: <select-all-action> select-all-action

TUPLE: left-action ;        C: <left-action> left-action
TUPLE: right-action ;       C: <right-action> right-action
TUPLE: up-action ;          C: <up-action> up-action
TUPLE: down-action ;        C: <down-action> down-action

TUPLE: zoom-in-action ;     C: <zoom-in-action> zoom-in-action
TUPLE: zoom-out-action ;    C: <zoom-out-action> zoom-out-action

! Modifiers
SYMBOLS: C+ A+ M+ S+ ;

TUPLE: key-down mods sym ;

: <key-gesture> ( mods sym action? class -- mods' sym' )
    [ [ [ S+ swap remove f like ] dip ] unless ] dip boa ; inline

: <key-down> ( mods sym action? -- key-down )
    key-down <key-gesture> ;

TUPLE: key-up mods sym ;

: <key-up> ( mods sym action? -- key-up )
    key-up <key-gesture> ;

! Hand state

! Note that these are only really useful inside an event
! handler, and that the locations hand-loc and hand-click-loc
! are in the co-ordinate system of the world which contains
! the gadget in question.
SYMBOL: hand-gadget
SYMBOL: hand-world
SYMBOL: hand-loc
{ 0 0 } hand-loc set-global

SYMBOL: hand-clicked
SYMBOL: hand-click-loc
SYMBOL: hand-click#
SYMBOL: hand-last-button
SYMBOL: hand-last-time
0 hand-last-button set-global
<zero> hand-last-time set-global

SYMBOL: hand-buttons
V{ } clone hand-buttons set-global

SYMBOL: scroll-direction
{ 0 0 } scroll-direction set-global

SYMBOL: double-click-timeout
300 milliseconds double-click-timeout set-global

: hand-moved? ( -- ? )
    hand-loc get hand-click-loc get = not ;

: button-gesture ( gesture -- )
    hand-clicked get-global propagate-gesture ;

: drag-gesture ( -- )
    hand-buttons get-global
    [ first <drag> button-gesture ] unless-empty ;

SYMBOL: drag-timer

<box> drag-timer set-global

: start-drag-timer ( -- )
    hand-buttons get-global empty? [
        [ drag-gesture ]
        300 milliseconds hence
        100 milliseconds
        add-alarm drag-timer get-global >box
    ] when ;

: stop-drag-timer ( -- )
    hand-buttons get-global empty? [
        drag-timer get-global ?box
        [ cancel-alarm ] [ drop ] if
    ] when ;

: fire-motion ( -- )
    hand-buttons get-global empty? [
        T{ motion } hand-gadget get-global propagate-gesture
    ] [
        drag-gesture
    ] if ;

: hand-gestures ( new old -- )
    drop-prefix <reversed>
    T{ mouse-leave } swap each-gesture
    T{ mouse-enter } swap each-gesture ;

: forget-rollover ( -- )
    f hand-world set-global
    hand-gadget get-global
    [ f hand-gadget set-global f ] dip
    parents hand-gestures ;

: send-lose-focus ( gadget -- )
    T{ lose-focus } swap send-gesture ;

: send-gain-focus ( gadget -- )
    T{ gain-focus } swap send-gesture ;

: focus-child ( child gadget ? -- )
    [
        dup focus>> [
            dup send-lose-focus
            f swap t focus-child
        ] when*
        dupd (>>focus) [
            send-gain-focus
        ] when*
    ] [
        (>>focus)
    ] if ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] with filter
    0 <column> prune [ f ] [ >array ] if-empty ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-rel ( gadget -- loc )
    hand-loc get-global swap screen-loc v- ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global swap screen-loc v- ;

: multi-click-timeout? ( -- ? )
    now hand-last-time get time- double-click-timeout get before=? ;

: multi-click-button? ( button -- button ? )
    dup hand-last-button get = ;

: multi-click-position? ( -- ? )
    hand-loc get hand-click-loc get distance 10 <= ;

: multi-click? ( button -- ? )
    {
        { [ multi-click-timeout?  not ] [ f ] }
        { [ multi-click-button?   not ] [ f ] }
        { [ multi-click-position? not ] [ f ] }
        { [ multi-click-position? not ] [ f ] }
        [ t ]
    } cond nip ;

: update-click# ( button -- )
    global [
        dup multi-click? [
            hand-click# inc
        ] [
            1 hand-click# set
        ] if
        hand-last-button set
        now hand-last-time set
    ] bind ;

: update-clicked ( -- )
    hand-gadget get-global hand-clicked set-global
    hand-loc get-global hand-click-loc set-global ;

: under-hand ( -- seq )
    hand-gadget get-global parents <reversed> ;

: move-hand ( loc world -- )
    dup hand-world set-global
    under-hand [
        over hand-loc set-global
        pick-up hand-gadget set-global
        under-hand
    ] dip hand-gestures ;

: send-button-down ( gesture loc world -- )
    move-hand
    start-drag-timer
    dup #>>
    dup update-click# hand-buttons get-global push
    update-clicked
    button-gesture ;

: send-button-up ( gesture loc world -- )
    move-hand
    dup #>> hand-buttons get-global delete
    stop-drag-timer
    button-gesture ;

: send-wheel ( direction loc world -- )
    move-hand
    scroll-direction set-global
    T{ mouse-scroll } hand-gadget get-global propagate-gesture ;

: send-action ( world gesture -- )
    swap world-focus propagate-gesture ;

GENERIC: gesture>string ( gesture -- string/f )

: modifiers>string ( modifiers -- string )
    [ name>> ] map concat >string ;

M: key-down gesture>string
    dup mods>> modifiers>string
    swap sym>> append ;

M: button-up gesture>string
    [
        dup mods>> modifiers>string %
        "Click Button" %
        #>> [ " " % # ] when*
    ] "" make ;

M: button-down gesture>string
    [
        dup mods>> modifiers>string %
        "Press Button" %
        #>> [ " " % # ] when*
    ] "" make ;

M: left-action gesture>string drop "Swipe left" ;

M: right-action gesture>string drop "Swipe right" ;

M: up-action gesture>string drop "Swipe up" ;

M: down-action gesture>string drop "Swipe down" ;

M: zoom-in-action gesture>string drop "Zoom in" ;

M: zoom-out-action gesture>string drop "Zoom out (pinch)" ;

M: object gesture>string drop f ;
