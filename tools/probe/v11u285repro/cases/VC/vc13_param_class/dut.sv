// § clsImpCopyTdBindsContainerListing285
// a parameterized class in the container
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; class c #(int N = 1); int own [N]; endclass endpackage
module top; q::c #(2) h; endmodule
