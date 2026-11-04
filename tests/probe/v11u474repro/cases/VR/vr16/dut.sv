// § clsScopedRangeKept474 (attack: $unit class)
class S; localparam w = 8; endclass
module top;
  wire [S::w-1:0] a;
  logic [S::w:1] b;
endmodule
