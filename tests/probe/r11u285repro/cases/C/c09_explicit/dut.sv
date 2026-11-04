// § clsImpCopyTdBindsContainerListing285
// an explicit import of the variable (and the type)
package p; typedef struct { int a; } t; t v; t w; endpackage
package q; import p::t; import p::v; class c; int own; endclass endpackage
module top; q::c h; endmodule
