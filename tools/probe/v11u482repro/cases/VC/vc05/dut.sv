// § cloneOwnCopyInstHomeTop482 (struct with a struct-typedef member, scalar local)
package u;
  typedef struct { int k; int data; } in_t;
  typedef struct { in_t i; int z; } op_t;
  function int f(int n);
    op_t s;
    s.i.data = n;
    return s.i.data;
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
