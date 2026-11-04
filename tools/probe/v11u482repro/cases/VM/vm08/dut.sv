// § cloneHierMemberChain482 (member chain inside a module function (no clone))
package u;
  typedef struct { int k; int data; } in_t;
  typedef struct { in_t i; int z; } op_t;
endpackage
module top;
  import u::*;
  function int f(int n);
    op_t acc[2];
    acc[0].z = n;
    return acc[1].i.data;
  endfunction
  int x;
  initial x = f(1);
endmodule
