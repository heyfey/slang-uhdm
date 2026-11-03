// § clsScopedRangeKept474 (attack: two instances of a child module)
package p; class S; localparam w = 8; endclass endpackage
module sub; import p::*;
  logic [S::w-1:0] a;
endmodule
module top; sub u1(); sub u2(); endmodule
