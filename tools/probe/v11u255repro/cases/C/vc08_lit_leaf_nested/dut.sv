// § defGenCfcLitLeafSel255 (a literal leaf on a two-member path)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] sel; logic [3:0] en; logic [1:0][1:0] m; padsel_t a; } reg2hw_t;
endpackage
module dut (input pp::reg2hw_t reg2hw, input logic [15:0] d, output logic [1:0] o);
  function automatic logic f(input logic x); return x; endfunction
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = reg2hw.a.q[2];
  end
endmodule
module top;
  pp::reg2hw_t r;
  logic [1:0] o;
  dut u (.reg2hw(r), .d(16'h0), .o(o));
endmodule
