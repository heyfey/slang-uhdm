// § cloneArrElemAggOwnCopy482 (queue of a struct with packed vector members)
package u;
  typedef struct { logic [7:0] a; bit [3:0] b; } op_t;
  function int f(int n);
    op_t acc[$];
    acc.push_back('{a: n, b: 1});
    return acc[0].a;
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
