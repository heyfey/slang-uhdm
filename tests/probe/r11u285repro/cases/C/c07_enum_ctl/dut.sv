// § clsImpCopyTdBindsContainerListing285
// control: an enum typedef (the law reads structs and unions only)
package p; typedef enum { A, B } e_t; e_t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
