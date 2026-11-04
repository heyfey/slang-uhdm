// § cloneHierMemberChain482 (member chain on a queue element acc[0].i.data)
package u;
  typedef struct { int k; int data; } in_t;
  typedef struct { in_t i; int z; } op_t;
  function int f(int n);
    op_t acc[$];
    op_t e;
    acc.push_back(e);
    acc[0].i.k = n;
    return acc[0].i.data;
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
