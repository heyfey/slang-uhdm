// § clsImpCopyTdBindsContainerListing285
// a nested class inherits the outer class's container
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; class o; class n; int x; endclass endclass endpackage
module top; q::o h; endmodule
