// § clsImpCopyTdBindsContainerListing285
// two importing packages, each with a class
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
package r; import p::*; class d; int own; endclass endpackage
module top; q::c h; r::d k; endmodule
