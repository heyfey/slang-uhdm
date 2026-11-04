// § cloneAliasCopyBareName484 (alias of a struct holding a member typed by a third package's struct)
package s;
  typedef struct { int i; } in_t;
endpackage
package u;
  typedef struct { s::in_t m; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc[2];
    acc[0].data = n;
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
