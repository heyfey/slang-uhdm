// § varInitOpCastKept404
module top();
  int b = 7;
  int a = 3 + 4;
  int c = b + 1;
  logic [7:0] d = 8'h3 | 8'h4;
  int e = int'(b);
  int f = -b;
endmodule
