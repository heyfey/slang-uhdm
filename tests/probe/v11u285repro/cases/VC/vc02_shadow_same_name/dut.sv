// § clsImpCopyTdBindsContainerListing285
// the container declares its own struct typedef of the same name
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; typedef struct { int a; } t; class c; int own; endclass endpackage
module top; q::c h; endmodule
