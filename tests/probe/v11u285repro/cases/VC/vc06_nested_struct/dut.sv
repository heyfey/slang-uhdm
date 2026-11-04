// § clsImpCopyTdBindsContainerListing285
// a struct whose member is another struct typedef
package p; typedef struct { int x; } i_t; typedef struct { i_t a; int b; } t; t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
