// § fixArrLocalNamedAggElemTs480 (class-scoped struct typedef in a class method)
package u;
  class C;
    typedef struct { int k; int data; } op_t;
    function int f(int n);
      op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    endfunction
  endclass
endpackage
module top;
  import u::*;
  C c;
endmodule
