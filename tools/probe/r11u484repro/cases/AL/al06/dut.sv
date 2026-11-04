// § cloneAliasCopyBareName484 (an alias of an alias, fixed array)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  typedef op2_t op3_t;
  function int f(int n);
    op3_t acc[2];
    acc[0].k = n;
    return acc[1].data;
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
