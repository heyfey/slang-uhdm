// § castRhsClonePerInst176
`define CA(l, v) assign l = int'(v);
`define L q
module sub();
  parameter int X = 7;
  parameter logic [X-1:0] Y = '1;
  `CA(a, Y)
  assign `L = 16'(Y);
endmodule
module top();
  sub u0();
  sub #(.X(2)) u1();
endmodule
