// § clsImpCopyTdBindsContainerListing285
// the container also declares its own variable of the imported type
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; t qv; class c; int own; endclass endpackage
module top; q::c h; endmodule
