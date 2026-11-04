// § tfFormalTdCloneFile196: two headers each declaring functions over the same typedef, the formal in a macro body defined and expanded in dut.sv
`define ARG(nm) it_t nm
package p;
`include "types.svh"
`include "fa.svh"
  function automatic int h(`ARG(q));
    return q;
  endfunction
endpackage
module top;
  import p::*;
endmodule
