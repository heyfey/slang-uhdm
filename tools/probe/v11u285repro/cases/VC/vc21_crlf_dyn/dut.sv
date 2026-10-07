// § clsImpCopyTdBindsContainerListing285
// CRLF line ends, a dynamic array and a queue
package p; typedef struct { int a; } t; t v []; t w [$]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
