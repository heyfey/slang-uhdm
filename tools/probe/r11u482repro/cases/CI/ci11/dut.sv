// § cloneOwnCopyInstHomeTop482 (scalar struct local)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t s;
    s.k = n;
    return s.data;
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
