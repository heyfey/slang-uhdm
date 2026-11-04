// § cloneLhsIdxPartSelBind450
package p;
  function automatic void f(int i0);
    logic [15:0] d;
    d[i0+:8] = 1;
  endfunction
endpackage
module top;
  import p::*;
  logic [15:0] d;
  int i0;
  initial d[i0+:8] = 1;
endmodule
