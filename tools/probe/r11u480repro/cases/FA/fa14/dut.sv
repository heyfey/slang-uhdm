// § fixArrLocalNamedAggElemTs480 (out-of-body class method, package struct, one importer module)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2];
    int r;
    r = acc[1].data;
    return r;
  endfunction
endpackage
module top;
  import u::*;
  C c;
endmodule
