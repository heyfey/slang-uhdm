// § clsScopedRangeKept474 (attack: mixed with a package parameter)
package p; localparam P = 2; class S; localparam w = 8; endclass endpackage
module top; import p::*;
  wire [S::w+p::P-1:0] a;
  wire [S::w+P-1:0] b;
endmodule
