// § clsImpCopyTdBindsContainerListing285
// a packed struct typedef
package p; typedef struct packed { logic [3:0] a; logic b; } t; t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
