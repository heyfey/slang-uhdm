// § clsScopedRangeKept474 (attack: module-local class)
module top;
  class S; localparam w = 8; endclass
  wire [S::w-1:0] a;
endmodule
