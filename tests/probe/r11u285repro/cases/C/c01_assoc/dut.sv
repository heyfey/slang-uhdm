// § clsImpCopyTdBindsContainerListing285
// a class in package q inherits p's associative array of a struct typedef
package p; typedef struct { int a; int b; } t; t m [string]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
