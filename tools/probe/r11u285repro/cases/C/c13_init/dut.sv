// § clsImpCopyTdBindsContainerListing285
// a struct variable with an initializer
package p; typedef struct { int a; int b; } t; t v = '{1, 2}; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
