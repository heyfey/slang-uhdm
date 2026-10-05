// § cloneBlockFixedArrTsParented244
package p;
  localparam int N = 3;
  class fac;
    function int emit();
      int r;
      begin : blk
        int q[N];
        int w[N-1:0];
        q[0] = N;
        w[0] = q[0];
        r = w[0];
      end
      return r;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
