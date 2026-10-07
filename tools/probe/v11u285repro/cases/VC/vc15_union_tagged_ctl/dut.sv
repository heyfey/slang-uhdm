// § clsImpCopyTdBindsContainerListing285
// an unpacked union variable and a struct variable side by side
package p; typedef union { int a; shortint b; } u_t; typedef struct { int a; } t; u_t uv; t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
