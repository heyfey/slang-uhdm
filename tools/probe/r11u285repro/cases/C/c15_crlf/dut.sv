// § clsImpCopyTdBindsContainerListing285
// CRLF line ends
package p; typedef struct { int a; } t; t v [string]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
