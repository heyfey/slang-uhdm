// § cloneLhsIdxPartSelBind450
package p;
  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  function automatic void f(int i0);
    s_t s;
    logic [7:0] arr [4];
    s.f[i0+:4] = 1;
    arr[i0][i0+:2] = 1;
    arr[i0] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
