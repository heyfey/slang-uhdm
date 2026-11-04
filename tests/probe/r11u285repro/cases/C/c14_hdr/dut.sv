// § clsImpCopyTdBindsContainerListing285
// the typedef and the variable from an included header
package p; `include "inc.svh"
endpackage
package q; import p::*; class c; int own; endclass endpackage
module top; q::c h; endmodule
