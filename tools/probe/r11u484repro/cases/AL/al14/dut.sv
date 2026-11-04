// § cloneAliasCopyBareName484 (alias formal and alias return of a cloned function)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function op2_t f(op2_t a);
    op2_t r;
    r = a;
    return r;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); op_t z; z = f(z); return z.k; endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
