// § tfArgOutsideCopyOrder193
`include "pk.svh"
module dut import pk::*; (input s_t i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
