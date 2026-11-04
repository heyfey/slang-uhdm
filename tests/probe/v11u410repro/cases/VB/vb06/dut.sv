// § classPropBasedLitKept410
class C;
  logic [7:0] a = 4'b1010;
  logic [7:0] b = 4'd9;
  logic [7:0] c = 4'hA;
  logic [7:0] d = 3'o5;
  int e = 3'b101;
endclass
module top; C c = new; endmodule
