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
program prg (input logic [1:0] i);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  logic r;
  initial r = f(i);
endprogram
module aaa import pk::*; (input s_t i, output logic o);
  assign o = i.a ^ P[0].b;
endmodule
module dut import pk::*; (input s_t i, output logic o);
  aaa ua (.i(i), .o(o));
  prg up (.i(i));
endmodule
