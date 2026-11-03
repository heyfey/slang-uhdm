// § clsScopedRangeKept474 (attack: variable with initializer, bit type)
package p; class S; localparam w = 8; endclass endpackage
module top; import p::*;
  bit [S::w-1:0] b = 3;
  logic [S::w-1:0] l = '1;
endmodule
