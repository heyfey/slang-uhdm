// § clsImpCopyTdBindsContainerListing285
// a two-dimension unpacked array of the struct
package p; typedef struct { int a; } t; t v [2][3]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
