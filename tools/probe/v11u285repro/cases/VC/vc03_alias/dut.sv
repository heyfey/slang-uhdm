// § clsImpCopyTdBindsContainerListing285
// the variable typed by a typedef alias of the struct typedef
package p; typedef struct { int a; int b; } t; typedef t t2; t2 v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
