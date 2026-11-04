// § cloneOwnCopyInstHomeTop482 (associative array of a struct)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[int];
    acc[n].k = 1;
    return acc[n].data;
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
