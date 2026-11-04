// § fixArrLocalNamedAggElemTs480 (function in a package reached by a class of an importing package)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
endpackage
package a;
  import u::*;
  class K;
    function int g(); return f(1); endfunction
  endclass
endpackage
module top;
  import a::*;
  K k;
endmodule
