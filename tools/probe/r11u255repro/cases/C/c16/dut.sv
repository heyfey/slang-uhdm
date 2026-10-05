// § defGenCfcLitLeafSel255 (two literal-index leaves under an operation in a generate-if body)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; logic [3:0][3:0] m; } reg2hw_t;
endpackage
module pinmux #(parameter bit P = 1) (input pp::reg2hw_t reg2hw, output logic o);
  if (P) begin : g
    assign o = reg2hw.en[0] & reg2hw.en[1];
  end
endmodule
module top; pp::reg2hw_t r; logic o; pinmux u (.reg2hw(r), .o(o)); endmodule
