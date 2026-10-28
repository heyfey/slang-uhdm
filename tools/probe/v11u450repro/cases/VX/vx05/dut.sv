// § cloneLhsIdxPartSelBind450
package p;
  function automatic void f(int i0);
    logic [15:0] d;
    logic e;
    {d[i0+:4], e} = 5'h1;
    if (d[i0+:2] == 0) d[i0+:2] = 1;
    for (int j = 0; j < 2; j++) d[j*4+:4] = j;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
