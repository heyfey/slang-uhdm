// § clsImpCopyTdBindsContainerListing285
// a const struct variable with a pattern initializer
package p; typedef struct { int a; int b; } t; const t v = '{a: 1, b: 2}; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
