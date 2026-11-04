// § cloneAliasCopyBareName484 (union alias, fixed array)
package u;
  typedef union packed { int k; bit [31:0] data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc[2];
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
