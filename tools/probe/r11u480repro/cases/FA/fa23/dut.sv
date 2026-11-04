// § fixArrLocalNamedAggElemTs480 (a typedef of a parameterized class)
package u;
  class P #(int W = 4);
    typedef struct { logic [W-1:0] k; int data; } op_t;
  endclass
  class C;
    function int f(int n);
      P#(8)::op_t acc[2];
      acc[0].data = n;
      return acc[0].data;
    endfunction
  endclass
endpackage
module top;
  import u::*;
  C c;
endmodule
