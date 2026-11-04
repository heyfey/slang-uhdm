// § cloneLhsIdxPartSelBind450
package p;
  logic [15:0] pv;
  logic [3:0][7:0] pa;
  function automatic void f(int i0);
    pv[i0*8+:8] = 1;
    pa[i0][1] = 1;
    pa[i0+:2] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
