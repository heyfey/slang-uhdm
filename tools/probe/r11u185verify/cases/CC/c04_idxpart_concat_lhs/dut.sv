// § castRhsClonePerInst176
module sub();
  parameter int X = 8;
  parameter int K = 1;
  parameter logic [X-1:0] Y = '1;
  wire [15:0] a;
  wire [3:0] n2;
  assign a[K*4 +: 4] = 4'(Y);
  assign a[15-:4] = 4'(Y);
  assign {n1, n2} = 5'(Y);
endmodule
module top();
  sub u0();
  sub #(.X(3), .K(2)) u1();
endmodule
