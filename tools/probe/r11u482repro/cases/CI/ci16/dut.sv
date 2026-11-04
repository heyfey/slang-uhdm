// § cloneTfVarParentAtTf482 (struct typedef of a third package s imported by u; law 1 abstains)
package s;
  typedef struct { int k; int data; } op_t;
endpackage
package u;
  import s::*;
  function int f(int n);
    op_t acc[2];
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
