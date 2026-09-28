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
`include "wr.svh"
module aaa import pk::*; (input s_t i, output logic o);
  assign o = i.a ^ P[0].b;
endmodule
module zzz import pk::*; (input s_t i, output logic o);
  assign o = i.b ^ P[1].a;
endmodule
module dut import pk::*; (input s_t i, output logic o1, output logic o2, output logic o3);
  aaa ua (.i(i), .o(o1));
  mmm um (.i(i), .o(o2));
  zzz uz (.i(i), .o(o3));
endmodule
