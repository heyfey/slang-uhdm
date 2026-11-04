// § clsScopedRangeKept474 (attack: typedef alias of the class)
package p; class S; localparam w = 8; endclass endpackage
module top; import p::*;
  typedef S S_t;
  wire [S_t::w-1:0] a;
endmodule
