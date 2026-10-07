// § clsImpCopyTdBindsContainerListing285
// a packed union variable
package p; typedef union packed { logic [7:0] a; logic [7:0] b; } u_t; u_t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
