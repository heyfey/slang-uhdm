// § cloneOwnCopyInstHomeTop482 (struct return type)
package u;
  typedef struct { int k; int data; } op_t;
  function op_t f(int n);
    f.k = n;
    f.data = n;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); op_t q; q = f(1); return q.data; endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
