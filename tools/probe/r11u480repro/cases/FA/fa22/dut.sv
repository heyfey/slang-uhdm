// § fixArrLocalNamedAggElemTs480 (a typedef of another class, D::op_t)
package u;
  class D;
    typedef struct { int k; int data; } op_t;
  endclass
  class C;
    function int f(int n);
      D::op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    endfunction
  endclass
endpackage
module top;
  import u::*;
  C c;
endmodule
