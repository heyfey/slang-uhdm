// § clsImpCopyTdBindsContainerListing285
// three packages: the class sits in a package that imports the source through another
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; endpackage
package r; import q::*; import p::*; class c; int own; endclass endpackage
module top; r::c h; endmodule
