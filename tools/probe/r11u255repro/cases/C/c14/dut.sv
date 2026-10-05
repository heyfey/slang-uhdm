// § defGenCfcThroughCondSel255 (a ?: inside a gen-if condition: abstains)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux #(parameter pp::reg2hw_t R = '0) (output logic o);
  if (R.en[0] ? R.en[1] : R.m[1][0]) begin : g
    assign o = 1'b1;
  end else begin : h
    assign o = 1'b0;
  end
endmodule
module top; logic o; pinmux u (.o(o)); endmodule
