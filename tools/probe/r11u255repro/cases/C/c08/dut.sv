// § defGenCfcThroughCondSel255 (?: arms with literal-index and plain member paths)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux (input pp::reg2hw_t reg2hw, output logic [3:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = reg2hw.en[0] ? reg2hw.wkup_detector_padsel[1].q : reg2hw.m[2];
  end
endmodule
module top; pp::reg2hw_t r; logic [3:0] o [2]; pinmux u (.reg2hw(r), .o(o)); endmodule
