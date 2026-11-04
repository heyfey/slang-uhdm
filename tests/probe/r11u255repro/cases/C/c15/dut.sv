// § defGenCfcLitLeafSel255 (a literal-index leaf on the plain right side, a literal middle select beside it)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux (input pp::reg2hw_t reg2hw, output logic [1:0] o, output logic [3:0] o2);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = reg2hw.en[0];
  end
  for (genvar k = 0; k < 1; k++) begin : g2
    assign o2 = reg2hw.wkup_detector_padsel[1].q;
  end
endmodule
module top; pp::reg2hw_t r; logic [1:0] o; logic [3:0] o2; pinmux u (.reg2hw(r), .o(o), .o2(o2)); endmodule
