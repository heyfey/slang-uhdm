// § clsImpCopyTdBindsContainerListing285
// a class inside a program importing the package (the container is no package)
package p; typedef struct { int a; } t; t v; endpackage
program pr; import p::*; class c; int own; endclass c h; endprogram
module top; endmodule
