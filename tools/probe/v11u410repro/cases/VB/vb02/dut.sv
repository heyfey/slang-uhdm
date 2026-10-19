// § classPropBasedLitKept410
class C;
  byte a = 8'HFF;
  int b = 12'd100;
  longint c = 64'hFFFFFFFFFFFFFFFF;
  logic [3:0] d = 8'b10101010;
endclass
module top; C c = new; endmodule
