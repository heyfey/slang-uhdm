// § cloneBlockFixedArrTsParented244
package p;
  localparam int N = 3;
  class fac;
    extern function int emit();
  endclass
  function int fac::emit();
    int r;
    begin : blk
      int q[N];
      int w[N-1:0];
      int z[$clog2(N*4)];
      q[0] = N;
      w[0] = q[0];
      z[0] = w[N-1];
      r = z[0];
    end
    return r;
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
