// § cloneVarSelBind450
package p;
  function automatic void f(output logic [3:0][7:0] m, input int i0);
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
