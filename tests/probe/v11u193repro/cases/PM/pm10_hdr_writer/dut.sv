// § tfArgOutsideCopyOrder193
package pk;
  typedef struct packed {
    logic a;
    logic b;
  } s_t;
  parameter s_t P[2] = '{
    '{a: 1'b0, b: 1'b1},
    '{a: 1'b1, b: 1'b0}
  };
endpackage
module aaa (input logic [1:0] i, output logic o);
`include "wr.svh"
  assign o = f(i);
endmodule
module dut import pk::*; (input s_t i, output logic o, output logic o2);
  aaa u (.i(i), .o(o));
  assign o2 = P[0].a ^ i.a;
endmodule
