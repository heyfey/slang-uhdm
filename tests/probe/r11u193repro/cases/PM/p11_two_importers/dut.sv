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
module aaa import pk::*; (input s_t i, output logic o);
  assign o = i.b ^ P[0].a;
endmodule
module dut import pk::*; (input s_t i, output logic o, output logic o2);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  aaa u (.i(i), .o(o2));
  assign o = f(i);
endmodule
