// § cloneAliasCopyBareName484 (a packed struct alias whose struct holds an enum member)
package u;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { e_t e; logic [7:0] data; } op_t;
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
