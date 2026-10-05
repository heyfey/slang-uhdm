// § defGenCfcThroughCondSel255 (a parameter path as the index of the assignment TARGET: abstains)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux #(parameter pp::reg2hw_t R = '0) (input logic [15:0] d, output logic [15:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    assign o[R.wkup_detector_padsel[1]] = d[k];
  end
endmodule
module top; logic [15:0] o; pinmux u (.d(16'h0), .o(o)); endmodule
