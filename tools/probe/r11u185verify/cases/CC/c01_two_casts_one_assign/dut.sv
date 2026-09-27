// § castRhsClonePerInst176
module sub();
  parameter int X = 20;
  parameter int Z = 3;
  typedef logic [X-1:0] t_t;
  parameter t_t Y = '1;
  assign a = int'(Y) + int'(Z);
  assign b = int'(int'(Y) + 1);
  assign c = 8'(Y) - 8'(Z);
endmodule
module top();
  sub u0();
  sub #(.X(5), .Z(1)) u1();
endmodule
