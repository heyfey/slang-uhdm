// § cloneLhsIdxPartSelBind450
package p;
  function automatic void f();
    logic [15:0] d;
    int k;
    k = 1;
    d[k+:8] = 1;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
