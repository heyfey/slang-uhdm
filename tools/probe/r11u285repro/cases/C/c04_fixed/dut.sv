// § clsImpCopyTdBindsContainerListing285
// a fixed unpacked array of a struct typedef
package p; typedef struct { int a; } t; t f [2]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
