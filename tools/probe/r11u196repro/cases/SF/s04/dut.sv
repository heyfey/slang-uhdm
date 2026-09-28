// § tfFormalTdCloneFile196: a formal type written inside a macro body and an unpacked-array formal of a scalar typedef, in an included header
package p;
`include "types.svh"
`include "fns.svh"
endpackage
module top;
  import p::*;
  it_t w;
endmodule
