// § castRhsClonePerInst176
module sub #(type T = logic [3:0], parameter int P = 9) ();
  assign o = T'(P);
  wire [15:0] d;
  assign d = T'(P + 1);
endmodule
module top();
  sub u0();
  sub #(.T(logic [7:0]), .P(300)) u1();
endmodule
