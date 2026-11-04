// § cloneOwnCopyInstHomeTop482 (two packages each declaring a struct op_t, both cloned)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t s;
    s.data = n;
    return s.data;
  endfunction
endpackage
package v;
  typedef struct { int z; } op_t;
  function int fv(int n);
    op_t s;
    s.z = n;
    return s.z;
  endfunction
endpackage
package a;
  import u::*;
  import v::*;
  function int g(); return f(1) + fv(2); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
