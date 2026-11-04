// § classPropBasedLitKept410
class C;
  logic [7:0] a = 4'hf;
  bit [3:0] b = 4'b1010;
  int c = 'hff;
  int d = 'o17;
endclass
module top; C c = new; endmodule
