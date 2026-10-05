// § defGenCfcThroughCondSel255 (nested gen-for blocks, the inner genvar in the path index)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] sel; logic [3:0] en; logic [1:0][1:0] m; padsel_t a; } reg2hw_t;
endpackage
module dut (input pp::reg2hw_t reg2hw, input logic [15:0] d, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    for (genvar j = 0; j < 1; j++) begin : h
      assign o[k] = reg2hw.en[j] ? d[reg2hw.sel[k]] : d[reg2hw.sel[j]];
    end
  end
endmodule
module top;
  pp::reg2hw_t r;
  logic [1:0] o;
  dut u (.reg2hw(r), .d(16'h0), .o(o));
endmodule
