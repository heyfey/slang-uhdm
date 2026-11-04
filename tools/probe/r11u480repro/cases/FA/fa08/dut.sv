// § fixArrLocalNamedAggElemTs480 (in-body class method, package struct typedef)
package p;
  typedef struct { int k; bit [7:0] data; } op_t;
  class C;
    function int f(int n);
      op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  C c;
endmodule
