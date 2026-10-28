// § cloneVarSelBind450
package p;
  function automatic void f(int i0);
    logic [7:0] u [4];
    u[i0][2] = 1;
    u[1][i0] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
