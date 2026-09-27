// § castRhsClonePerInst176
module sub();
  parameter int X = 5;
  parameter logic [X-1:0] Y = '1;
  assign a = int'(Y), b = 8'(Y), c = Y;
endmodule
module top();
  sub u0();
  sub #(.X(9)) u1();
endmodule
