// § fixArrLocalNamedAggElemTs480 (typedef of a typedef declared in a package, used by a module function)
package p;
  typedef struct { int k; int d; } base_t;
endpackage
module top;
  import p::*;
  typedef base_t op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
