// § cloneOwnCopyInstHomeTop482 (struct formal)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(op_t p);
    return p.data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); op_t q; q.data = 1; return f(q); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
