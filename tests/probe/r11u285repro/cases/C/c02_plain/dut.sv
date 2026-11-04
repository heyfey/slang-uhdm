// § clsImpCopyTdBindsContainerListing285
// a plain struct variable
package p; typedef struct { int a; logic [3:0] b; } t; t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
