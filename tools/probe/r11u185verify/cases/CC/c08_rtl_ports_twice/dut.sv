// § castRhsClonePerInst176
module sub #(parameter int X = 2) (input logic [3:0] i, output logic [7:0] o, output logic [3:0] p);
  assign o = 8'(i + X);
  assign p[1:0] = 2'(i);
  assign p[3:2] = 2'(i >> X);
endmodule
module top(input logic [3:0] i, output logic [7:0] o0, o1, output logic [3:0] p0, p1);
  sub u0(.i(i), .o(o0), .p(p0));
  sub #(.X(1)) u1(.i(i), .o(o1), .p(p1));
endmodule
