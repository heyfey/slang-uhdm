// § cloneVarSelBind450
package p;
  function automatic logic f(input logic [3:0][7:0] m, input int i0);
    return m[i0][3];
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
