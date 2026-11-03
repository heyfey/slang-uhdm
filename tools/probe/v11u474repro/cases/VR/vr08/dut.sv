// § clsScopedRangeKept474 (attack: control, typedef of the range, variable of the typedef)
package p; class S; localparam w = 8; endclass endpackage
module top; import p::*;
  typedef logic [S::w-1:0] t;
  t x;
endmodule
