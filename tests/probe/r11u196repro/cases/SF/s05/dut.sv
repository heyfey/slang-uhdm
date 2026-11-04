// § tfFormalTdCloneFile196: a module function formal typed by a package typedef declared in a header (the module and the formal in dut.sv)
package p;
`include "types.svh"
endpackage
module top;
  function automatic int f(p::it_t v, input p::it_t w);
    return v + w;
  endfunction
endmodule
