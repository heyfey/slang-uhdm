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
package pu;
  import pk::*;
  parameter s_t Q = P[1];
endpackage
module bbb (input logic [1:0] i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
module dut import pu::*; (input logic [1:0] i, output logic o1, output logic o2);
  bbb ub (.i(i), .o(o1));
  assign o2 = Q.a;
endmodule
