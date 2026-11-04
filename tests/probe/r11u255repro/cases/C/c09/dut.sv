// § defGenCfcThroughCondSel255 (?: arm with an expression index (pass 255's span law's CFC side))
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux (input pp::reg2hw_t reg2hw, output logic [3:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = reg2hw.en[k] ? reg2hw.wkup_detector_padsel[1-k].q : 4'h0;
  end
endmodule
module top; pp::reg2hw_t r; logic [3:0] o [2]; pinmux u (.reg2hw(r), .o(o)); endmodule
