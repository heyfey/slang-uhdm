// § cloneBitSelMemberBind265 (fresh: a two-dimensional member, rw.m[i][j], and a bit select of an unpacked-array member element)
package p;
  typedef struct { bit [3:0][7:0] m; bit [7:0] u [2]; } op_t;
  class c;
    extern function void f(int i, int j);
  endclass
  function void c::f(int i, int j);
    op_t rw;
    rw.m[i][j] = 1'b1;
    rw.m[i] = 8'h0;
    rw.u[1][j] = 1'b0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
