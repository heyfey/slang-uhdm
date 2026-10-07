// § clsImpCopyTdBindsContainerListing285
// a class in an interface importing the package (the container is no package)
package p; typedef struct { int a; } t; t v; endpackage
interface ifc; import p::*; class c; int own; endclass endinterface
module top; ifc u(); endmodule
