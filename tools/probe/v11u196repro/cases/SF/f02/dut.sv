// § tfFormalTdCloneFile196: a formal type written by a macro defined in one header and expanded in another header, plus output and ref formals
package p;
`include "defs.svh"
`include "types.svh"
`include "fns.svh"
endpackage
module top;
  import p::*;
endmodule
