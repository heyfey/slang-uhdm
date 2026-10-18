// § unbasedUntypedElabKeepsLiteral401
module sub #(parameter P = '0) (output logic [3:0] o);
  assign o = P;
endmodule
module top;
  logic [3:0] a, b;
  sub #(.P('1)) u1(.o(a));
  sub u2(.o(b));
endmodule
