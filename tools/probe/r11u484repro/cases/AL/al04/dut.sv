// § cloneAliasCopyBareName484 (formal of a home alias)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(op2_t a);
    return a.data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); op_t z; return f(z); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
