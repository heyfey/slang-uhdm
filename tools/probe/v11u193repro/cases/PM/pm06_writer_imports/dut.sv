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
module ccc import pk::*; (input logic [1:0] i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a ^ P[0].b;
  endfunction
  assign o = f(i);
endmodule
module bbb import pk::*; (output logic o);
  assign o = P[1].a;
endmodule
module ddd import pk::*; (output logic o);
  assign o = P[1].b;
endmodule
module dut (input logic [1:0] i, output logic o, output logic o2, output logic o3);
  ccc u (.i(i), .o(o));
  bbb b (.o(o2));
  ddd d (.o(o3));
endmodule
