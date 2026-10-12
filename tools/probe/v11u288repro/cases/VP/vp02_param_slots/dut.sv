// § parenCastReadsCastSyntax288 — a parenthesized cast in parameter defaults, localparams and an override
module m #(parameter int W = (int'(3)), parameter logic [7:0] P = (byte'(9)))(output logic [7:0] o);
  localparam int L = (int'(W + 1));
  localparam logic [3:0] Q = (4'(P));
  assign o = L + Q;
endmodule
module top(output logic [7:0] o, o2);
  m #(.W((int'(5)))) u(.o(o));
  m u2(.o(o2));
endmodule
