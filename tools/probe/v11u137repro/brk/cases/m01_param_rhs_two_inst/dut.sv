// § caLhsDefNetUnlessOpRhs139
module sub #(parameter logic [3:0] P = 4'd1)(output logic [3:0] y);
  assign y = P;
endmodule
module top(output logic [3:0] a, b);
  sub #(.P(4'd2)) u1(.y(a));
  sub u2(.y(b));
endmodule
