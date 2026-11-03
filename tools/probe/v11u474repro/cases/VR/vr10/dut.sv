// § clsScopedRangeKept474 (attack: parenthesized and multiplied bounds)
package p; class S; localparam w = 8; endclass endpackage
module top; import p::*;
  wire [(S::w)-1:0] a;
  wire [S::w*2-1:0] b;
  wire [S::w-1:S::w/2] c;
endmodule
