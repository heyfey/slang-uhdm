// § varInitOpCastKept404
module top;
  int x = int'(3.7);
  shortint y = shortint'(70000);
  logic [3:0] z = 4'(20);
  int s = signed'(4'b1111);
  real r = 1.5 * 2;
endmodule
