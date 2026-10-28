// § cloneVarSelBind450
package p;
  function automatic void f(int i0);
    logic [3:0][7:0] m;
    m[i0][i0+:2] = 1;
    m[i0+:2] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
