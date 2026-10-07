// § clsImpCopyTdBindsContainerListing285
// control: a class declared in a module (the container is not a package)
package p; typedef struct { int a; } t; t v; endpackage
module top; import p::*; class c; int own; endclass c h; endmodule
