// § clsImpCopyTdBindsContainerListing285
// two variables of two struct typedefs, one packed
package p; typedef struct { int a; } t; typedef struct packed { logic [3:0] u; } pk_t; t v; pk_t w; t z [$]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
