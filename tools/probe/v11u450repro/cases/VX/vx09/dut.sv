// § cloneVarSelBind450
package p;
  function automatic void f(int i0, ref logic [3:0][7:0] rm, inout logic [3:0][7:0] io);
    rm[i0][1] = 1;
    io[i0][2] = rm[i0][3];
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
