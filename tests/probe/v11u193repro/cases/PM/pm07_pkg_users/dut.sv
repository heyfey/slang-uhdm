// § tfArgOutsideCopyOrder193
package pk;
  typedef struct packed {
    logic a;
    logic b;
  } s_t;
  typedef s_t pair_t [2];
  typedef struct packed {
    s_t x;
    logic c;
  } w_t;
  parameter s_t P[2] = '{
    '{a: 1'b0, b: 1'b1},
    '{a: 1'b1, b: 1'b0}
  };
endpackage
module mmm (input logic [1:0] i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i);
endmodule
module dut import pk::*; (input s_t i, output logic o, output logic o2, output logic o3);
  w_t w;
  assign w = {i, 1'b0};
  mmm u (.i(i), .o(o));
  assign o2 = w.x.b;
  assign o3 = P[0].a ^ i.a;
endmodule
