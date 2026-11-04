// § modAliasShadowAbstain484v (module alias named like a typedef of a wildcard-imported package)
package p;
  typedef struct { int z; } op2_t;
endpackage
module top;
  import p::*;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
  int x;
  initial x = f(1);
endmodule
