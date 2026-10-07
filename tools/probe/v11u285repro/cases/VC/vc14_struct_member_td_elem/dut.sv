// § clsImpCopyTdBindsContainerListing285
// an associative array of the struct indexed by another struct-free typedef
package p; typedef int k_t; typedef struct { int a; k_t b; } t; t v [k_t]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
