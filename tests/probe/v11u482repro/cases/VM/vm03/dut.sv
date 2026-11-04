// § cloneHierMemberChain482 (packed struct member)
package u;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } p_t;
  typedef struct { p_t p; int z; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].p.x = n;
    return acc[1].p.y;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
