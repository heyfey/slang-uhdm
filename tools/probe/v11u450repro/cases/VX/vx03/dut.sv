// § cloneLhsIdxPartSelBind450
package p;
  parameter int P = 4;
  localparam int L = 2;
  function automatic void f(int i0);
    logic [15:0] d;
    d[P+:8] = 1;
    d[L*2-:2] = 1;
    d[i0-:2] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
