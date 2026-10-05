// § defGenCfcLitLeafSel255 (a literal-index leaf as the TARGET (the SEL writer): control)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux (output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    pp::reg2hw_t loc;
    assign loc.en[0] = 1'b0;
    assign o[k] = 1'b0;
  end
endmodule
module top; logic [1:0] o; pinmux u (.o(o)); endmodule
