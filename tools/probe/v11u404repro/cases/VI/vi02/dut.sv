// § varInitOpCastKept404
module top(input [7:0] n);
  parameter P = 5;
  int a = P + 1;
  logic [7:0] c = n + 1;
  bit e = (3 == 4);
  logic l = 1'b1 && 1'b0;
endmodule
