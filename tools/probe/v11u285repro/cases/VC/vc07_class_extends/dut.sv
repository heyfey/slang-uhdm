// § clsImpCopyTdBindsContainerListing285
// a derived class and its base class in the container
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; class b; int x; endclass class c extends b; int own; endclass endpackage
module top; q::c h; endmodule
