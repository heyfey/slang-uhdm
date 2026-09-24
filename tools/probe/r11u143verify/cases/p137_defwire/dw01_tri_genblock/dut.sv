// § unsignedScalarVecTsAtKeyword137 (refinement R11V137_DEFWIRE_OFF)
// case dw01: tri logic unsigned body nets inside a generate block, one with an initializer
module top(input logic i, output logic o);
  if (1) begin : g
    tri logic unsigned t;
    wire logic unsigned w = i;
    assign t = w;
    assign o = t;
  end
endmodule
