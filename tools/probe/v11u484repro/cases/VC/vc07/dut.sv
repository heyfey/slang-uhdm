// § cloneAliasCopyBareName484 (alias array of three elements and an alias struct copy assigned from another)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc[3];
    op_t one;
    one.k = n;
    acc[2] = one;
    return acc[2].k;
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
