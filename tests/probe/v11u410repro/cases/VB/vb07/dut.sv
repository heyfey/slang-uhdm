// § classPropBasedLitKept410
class C;
  bit [2:0] a = 5'b00101;
  byte b = 16'd5;
  shortint c = 20'hF0F0F;
  bit d = 2'b11;
endclass
module top; C c = new; endmodule
