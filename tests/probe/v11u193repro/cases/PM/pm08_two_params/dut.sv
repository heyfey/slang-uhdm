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
  parameter s_t R = '{a: 1'b1, b: 1'b1};
endpackage
module mmm (input logic [1:0] i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
module dut import pk::*; (input s_t i, output logic o, output logic o2, output logic o3);
  mmm u (.i(i), .o(o));
  assign o2 = P[0].a ^ i.a;
  assign o3 = R.b ^ i.b;
endmodule
module aaa import pk::*; (output logic o);
  assign o = R.a ^ o;
endmodule
