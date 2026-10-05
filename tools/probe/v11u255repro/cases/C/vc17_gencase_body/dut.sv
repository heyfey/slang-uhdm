// § defGenCfcThroughCondSel255 (a ?: with a selected path in a generate-case item)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] sel; logic [3:0] en; logic [1:0][1:0] m; padsel_t a; } reg2hw_t;
endpackage
module dut #(parameter int P = 1) (input pp::reg2hw_t reg2hw, input logic [15:0] d, output logic [1:0] o);
  case (P)
    1: begin : gc
      assign o[0] = reg2hw.en[0] ? d[reg2hw.sel[1]] : 1'b0;
    end
    default: ;
  endcase
endmodule
module top;
  pp::reg2hw_t r;
  logic [1:0] o;
  dut u (.reg2hw(r), .d(16'h0), .o(o));
endmodule
