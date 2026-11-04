// § clsImpCopyTdBindsContainerListing285
// two classes in one importing package
package p; typedef struct { int a; } t; t v [string]; endpackage
package q; import p::*; class c1; int x; endclass class c2; int y; endclass endpackage
module top; q::c1 h1; q::c2 h2; endmodule
