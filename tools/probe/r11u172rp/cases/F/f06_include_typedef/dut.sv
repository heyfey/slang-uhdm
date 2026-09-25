package pa;
`include "types.svh"
  function automatic logic f(s_t v);
    return v.y;
  endfunction
endpackage
module top(input pa::s_t i, output logic o);
  assign o = pa::f(i);
endmodule
