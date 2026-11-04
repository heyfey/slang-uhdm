// § cloneHierMemberChain482 (member typed by an alias of a struct)
package u;
  typedef struct { int k; int data; } in_t;
  typedef in_t in2_t;
  typedef struct { in2_t i; int z; } op_t;
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
