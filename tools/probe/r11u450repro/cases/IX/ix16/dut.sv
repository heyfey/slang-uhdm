// § cloneVarSelBind450
package p;
  function automatic void f(int i0);
    logic [3:0][7:0] m;
    logic [15:0] d;
    logic [7:0] x;
    m[i0][3] = 1;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
