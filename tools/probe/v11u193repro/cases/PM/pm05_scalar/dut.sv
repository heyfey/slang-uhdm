// § tfArgOutsideCopyOrder193
package pk;
  typedef struct packed {
    logic a;
    logic b;
  } s_t;
  parameter s_t Q = '{a: 1'b0, b: 1'b1};
endpackage
module aaa (input logic [1:0] i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
module dut import pk::*; (input s_t i, output logic o, output logic o2);
  aaa u (.i(i), .o(o));
  assign o2 = Q.b;
endmodule
module zzz import pk::*; (output logic o);
  assign o = Q.a;
endmodule
