// § cloneLhsIdxPartSelBind450
package p;
  function automatic int f(int i0);
    logic [15:0] d;
    logic [7:0] x;
    d = 16'h1234;
    x = d[i0*8+:8];
    if (d[i0*8+:4] == 0) x = 0;
    return x;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
