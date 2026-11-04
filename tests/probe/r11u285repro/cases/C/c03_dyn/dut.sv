// § clsImpCopyTdBindsContainerListing285
// a dynamic array and a queue of a struct typedef
package p; typedef struct { int a; } t; t d []; t qq [$]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
