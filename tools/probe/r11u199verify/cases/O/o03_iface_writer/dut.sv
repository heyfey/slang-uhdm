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
interface mif (input logic [1:0] i);
  function automatic logic f(pk::s_t x);
    return x.b;
  endfunction
  logic r;
  assign r = f(i);
endinterface
module zzz import pk::*; (input s_t i, output logic o);
  assign o = i.a ^ P[1].b;
endmodule
module dut import pk::*; (input s_t i, output logic o);
  mif ui (.i(i));
  zzz uz (.i(i), .o(o));
endmodule
