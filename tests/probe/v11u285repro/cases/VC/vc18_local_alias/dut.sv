// § clsImpCopyTdBindsContainerListing285
// the container aliases the imported typedef under the same name
package p; typedef struct { int a; } t; t v; endpackage
package q; import p::*; typedef p::t t; class c; int own; endclass endpackage
module top; q::c h; endmodule
