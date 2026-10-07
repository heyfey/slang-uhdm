// § clsImpCopyTdBindsContainerListing285
// the container re-exports the source package
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; export p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
