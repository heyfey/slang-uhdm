// § clsImpCopyTdBindsContainerListing285
// the same typedef header included into the source and the container package
package p; `include "td.svh"
 t v; endpackage
package q; `include "td.svh"
 import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
