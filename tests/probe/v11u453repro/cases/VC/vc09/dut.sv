// § vsTrailRangeColonJoin453
package p;
  class C #(int N = 2);
    function void f(int i0);
      logic [3:0][7:0] m;
      m[i0][i0+:N] = 1;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  C #(3) c = new;
endmodule
