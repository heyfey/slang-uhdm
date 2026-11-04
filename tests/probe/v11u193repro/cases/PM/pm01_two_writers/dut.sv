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
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
module zzz (input logic [1:0] i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
module mmm import pk::*; (input s_t i, output logic o);
  assign o = P[0].a ^ i.a;
endmodule
module dut import pk::*; (input s_t i, output logic o, output logic o2, output logic o3);
  aaa u (.i(i), .o(o));
  zzz z (.i(i), .o(o2));
  mmm m (.i(i), .o(o3));
endmodule
