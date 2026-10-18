// § unitParamXzLiteral404
parameter int a = 1'bz;
parameter int b = 4'b1x0z;
parameter int c = 'x;
parameter int d = '1;
parameter int e = 'z;
parameter int f = 8'hx;
parameter g = 1'bx;
parameter logic [3:0] h = 4'bx;
parameter int i = 1;
module test;
  parameter int ma = 1'bx;
  parameter int mb = '0;
endmodule
