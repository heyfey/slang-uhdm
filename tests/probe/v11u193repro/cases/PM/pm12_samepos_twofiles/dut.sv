// § tfArgOutsideCopyOrder193
`include "pk.svh"
module dut import pk::*; (input s_t i, output logic o, output logic o2);
  parameter s_t Z[2] = '{
    '{a: 1'b1, b: 1'b1},
    '{a: 1'b0, b: 1'b0}
  };
  zzz u (.i(i), .o(o));
  assign o2 = P[0].a ^ Z[1].b ^ i.a;
endmodule
module zzz (input logic [1:0] i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
