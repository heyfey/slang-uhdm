// § clsScopedRangeKept474 (attack: two packed dimensions)
package p; class S; localparam w = 8; endclass endpackage
module top; import p::*;
  logic [S::w-1:0][1:0] x;
  logic [1:0][S::w-1:0] y;
endmodule
