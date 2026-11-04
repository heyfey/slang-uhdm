// § clsPropBinLitTrunc410v
typedef logic [2:0] t3;
class C;
  t3 g = 5'b10101;
  int d = 36'b100000000000000000000000000000000001;
  int unsigned h = 34'b1000000000000000000000000000000011;
  integer i = 36'b100000000000000000000000000000000001;
endclass
module top; C c = new; endmodule
