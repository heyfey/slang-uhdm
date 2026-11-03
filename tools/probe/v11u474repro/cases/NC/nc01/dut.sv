// § clsScopedRangeKept474 (negative control: a generic class named with '::' without parameter assignments, which upstream slang rejects)
package p; class S #(int w = 8); endclass endpackage
module top; import p::*;
  wire [S::w-1:0] b;
endmodule
