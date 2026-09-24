// § defNetEndOnlyLoc130
// case a03: anonymous enum whose base width is a parameter, instance overrides it
module sub #(parameter int W = 2) (output logic [W-1:0] o);
  enum logic [W-1:0] {S0, S1, S2} st;
  assign o = st;
endmodule
module top(output logic [2:0] o);
  sub #(.W(3)) u(.o(o));
endmodule
