// § clsScopedRangeKept474 (attack: static class function call in a bound)
package p; class S; static function int f(); return 8; endfunction endclass endpackage
module top; import p::*;
  wire [S::f()-1:0] a;
endmodule
