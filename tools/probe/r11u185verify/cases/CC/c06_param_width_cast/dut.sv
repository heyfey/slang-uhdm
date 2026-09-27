// § castRhsClonePerInst176
module sub();
  parameter int X = 6;
  parameter logic [X-1:0] Y = '1;
  wire [31:0] a, b;
  assign a = X'(Y);
  assign b = (X+2)'(Y);
  assign c = unsigned'(Y);
endmodule
module top();
  sub u0();
  sub #(.X(3)) u1();
endmodule
