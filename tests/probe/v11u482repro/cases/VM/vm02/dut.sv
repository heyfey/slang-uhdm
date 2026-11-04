// § cloneHierMemberChain482 (union member inside a struct)
package u;
  typedef union { int i; bit [31:0] b; } un_t;
  typedef struct { un_t m; int z; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].m.i = n;
    return acc[1].m.i;
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
