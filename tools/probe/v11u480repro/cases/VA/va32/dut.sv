// § fixArrLocalNamedAggElemTs480 (typedef in a parameterized base class, specialized base)
package p;
  class B #(int W = 2);
    typedef struct { logic [W-1:0] k; } op_t;
  endclass
  class D extends B #(4);
    function int f(int n);
      op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  D d;
endmodule
