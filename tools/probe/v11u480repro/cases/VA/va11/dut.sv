// § fixArrLocalNamedAggElemTs480 (typedef of another package imported into the declaring package)
package a;
  typedef struct { int k; int data; } op_t;
endpackage
package b;
  import a::*;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
endpackage
module top;
  import b::*;
  int x;
  initial x = f(1);
endmodule
