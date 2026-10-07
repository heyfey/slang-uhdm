// § clsImpCopyTdBindsContainerListing285
// the struct comes from a third package that p imports
package r; typedef struct { int a; } t; endpackage
package p; import r::*; t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
