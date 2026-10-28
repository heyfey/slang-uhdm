// § cloneVarSelBind450
package p;
  class C;
    logic [3:0][7:0] m;
    logic [15:0] d;
    extern function void f(int i0);
  endclass
  function void C::f(int i0);
    m[i0][1] = 1;
    d[i0+:8] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
