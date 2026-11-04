// § clsImpCopyTdBindsContainerListing285
// the typedef written by a macro
`define MKT(n) typedef struct { int a; } n;
package p; `MKT(t) t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
