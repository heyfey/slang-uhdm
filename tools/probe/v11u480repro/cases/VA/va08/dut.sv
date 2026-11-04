// § fixArrLocalNamedAggElemTs480 (parameterized class, class struct typedef, two specializations)
package p;
  class C #(int W = 4);
    typedef struct { logic [W-1:0] k; int d; } op_t;
    function int f(int n);
      op_t acc[2];
      acc[0].d = n;
      return acc[0].d;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  C #(4) a;
  C #(8) b;
endmodule
