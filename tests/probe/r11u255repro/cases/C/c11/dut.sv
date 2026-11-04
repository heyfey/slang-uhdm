// § defGenCfcThroughCondSel255 (outside a generate block: control)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux (input pp::reg2hw_t reg2hw, input logic [15:0] d, output logic o);
  assign o = reg2hw.en[0] ? d[reg2hw.wkup_detector_padsel[1]] : 1'b0;
endmodule
module top; pp::reg2hw_t r; logic o; pinmux u (.reg2hw(r), .d(16'h0), .o(o)); endmodule
