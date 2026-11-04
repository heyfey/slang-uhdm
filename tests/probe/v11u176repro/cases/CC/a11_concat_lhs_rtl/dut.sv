// § castRhsClonePerInst176
module sub (input logic [7:0] i, output logic [3:0] a, output logic [3:0] b);
  assign {a, b} = 8'(i + 8'd3);
endmodule
module top (input logic [7:0] x, output logic [3:0] p, q, r, s);
  sub u1 (.i(x), .a(p), .b(q));
  sub u2 (.i(x), .a(r), .b(s));
endmodule
