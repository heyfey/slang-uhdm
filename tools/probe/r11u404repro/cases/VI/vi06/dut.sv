// § varInitOpCastKept404
module top();
  logic [7:0] a = 3 + 4;
  longint b = 3 + 4;
  int c = 3 * 4 + 2;
  logic [3:0] d = 'd3 + 4'd4;
  int e = (3 + 4);
  byte f = 300 - 1;
endmodule
