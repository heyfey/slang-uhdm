// § cloneLhsIdxPartSelBind450
package p;
  parameter W = 4;
  function automatic void f(int i0);
    logic [15:0] d;
    d[W+:8] = 1;
    d[i0+W+:4] = 2;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
