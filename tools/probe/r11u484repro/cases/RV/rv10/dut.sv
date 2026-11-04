// § aliasTdTargetTopView484 (package function local of a home alias of a third-package struct)
package s;
  typedef struct { int k; int data; } op_t;
endpackage
package u;
  typedef s::op_t op_t2;
  function int f(int n);
    op_t2 acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
