// § clsScopedRangeKept474 (attack: package variable)
package p; class S; localparam w = 8; endclass
  logic [S::w-1:0] pv;
endpackage
module top; import p::*; wire [7:0] o = pv; endmodule
