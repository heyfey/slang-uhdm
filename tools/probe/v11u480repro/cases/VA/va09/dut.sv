// § fixArrLocalNamedAggElemTs480 (package function, package imported by two modules)
package p;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
endpackage
module m1; import p::*; int x; initial x = f(1); endmodule
module m2; import p::*; int y; initial y = f(2); endmodule
module top; m1 a(); m2 b(); endmodule
