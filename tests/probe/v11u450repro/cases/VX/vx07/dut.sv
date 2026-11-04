// § cloneLhsIdxPartSelBind450
package p;
  function automatic void f(int i0);
    logic [15:0] d;
    logic [3:0][7:0] m;
    d[i0*8+:8] = 1;
    m[i0][3] = 1;
  endfunction
endpackage
package r1;
  import p::*;
  int k;
endpackage
package r2;
  import p::*;
  int k;
endpackage
module top;
  import r1::*;
  import r2::*;
endmodule
