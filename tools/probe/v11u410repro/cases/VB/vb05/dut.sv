// § classPropBasedLitKept410
class C;
  logic [3:0] a = 8'b10101010;
  logic [3:0] b = 8'd200;
  logic [3:0] c = 8'hAB;
  logic [3:0] d = 6'o57;
endclass
module top; C c = new; endmodule
