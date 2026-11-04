// § cloneHierMemberChain482 (member typed by a struct of a third package)
package s;
  typedef struct { int k; int data; } in_t;
endpackage
package u;
  typedef struct { s::in_t i; int z; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].z = n;
    return acc[1].i.data;
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
