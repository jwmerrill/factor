
USING: kernel namespaces namespaces.lib math sequences vars mortar
accessors slot-accessors x ;

IN: x.widgets.wm.workspace

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: workspace windows ;

C: <workspace> workspace

VAR: workspaces

VAR: current-workspace

: init-workspaces ( -- ) V{ } clone >workspaces ;

: add-workspace ( -- ) { } clone <workspace> workspaces> push ;

: mapped-windows ( -- seq )
dpy get $default-root <- children [ <- mapped? ] filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: switch-to-workspace ( n -- )
mapped-windows current-workspace> workspaces> nth (>>windows)
mapped-windows [ <- unmap drop ] each
dup workspaces> nth windows>> [ <- map drop ] each
current-workspace set* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: next-workspace ( -- )
current-workspace> 1+ dup workspaces> length <
[ switch-to-workspace ] [ drop ] if ;

: prev-workspace ( -- )
current-workspace> 1- dup 0 >=
[ switch-to-workspace ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: setup-workspaces ( n -- )
workspaces>
  [ drop ]
  [ init-workspaces [ add-workspace ] times 0 >current-workspace ]
if ;