// § clsScopedRangeKept474 (attack: class parameter with a default, generic class)
package p; class S #(int w = 8); endclass endpackage
module top; import p::*;
  wire [S#(4)::w-1:0] a;

endmodule
