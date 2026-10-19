// § clsPropBinLitTrunc410v
class C;
  logic [3:0] a = 8'b101;
  reg [3:0] b = 6'b111000;
  logic c = 2'b10;
  logic signed [3:0] e = 8'b11110000;
  bit [3:0] f = 8'b11110000;
endclass
module top; C c = new; endmodule
