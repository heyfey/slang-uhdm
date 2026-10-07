// § clsImpCopyTdBindsContainerListing285
// a package-qualified declaration type in the source package
package r; typedef struct { int a; } t; endpackage
package p; r::t v; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
