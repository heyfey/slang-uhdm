// § cloneAliasCopyBareName484 (home alias declared in the importing package named like a home typedef)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package a;
  import u::*;
  typedef struct { int z; } op2b_t;
  typedef op2b_t mine_t;
  function int g(); mine_t m; m.z = 2; return f(1) + m.z; endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
