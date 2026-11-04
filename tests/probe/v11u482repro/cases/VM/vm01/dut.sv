// § cloneHierMemberChain482 (three member levels acc[1].o.i.data)
package u;
  typedef struct { int k; int data; } in_t;
  typedef struct { in_t i; int y; } mid_t;
  typedef struct { mid_t o; int z; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].z = n;
    return acc[1].o.i.data;
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
