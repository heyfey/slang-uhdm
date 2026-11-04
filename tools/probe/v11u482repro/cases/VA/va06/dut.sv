// § cloneArrElemAggOwnCopy482 (dynamic array of a struct as a formal)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(op_t acc[], int n);
    return acc[0].data + n;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); op_t q[]; q = new[1]; return f(q, 1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
