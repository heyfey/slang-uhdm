// § clsImpCopyTdBindsContainerListing285
// an unpacked union typedef
package p; typedef union { int a; shortint b; } u_t; u_t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
