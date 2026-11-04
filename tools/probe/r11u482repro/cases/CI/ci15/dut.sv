// § cloneArrElemAggOwnCopy482 (struct with an enum member in a fixed array)
package u;
  typedef enum { A0, A1 } e_t;
  typedef struct { e_t k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = A1;
    return acc[1].data + n;
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
