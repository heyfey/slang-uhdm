// § vsTrailRangeColonJoin453
package p;
  class C;
    static function void f(int i0);
      logic [3:0][7:0] m;
      m[i0][3:2] = 1;
    endfunction
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
