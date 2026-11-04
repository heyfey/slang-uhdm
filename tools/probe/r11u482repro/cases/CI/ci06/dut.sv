// § cloneFixArrAggElemShared482 (out-of-body class method, class imported by a)
package u;
  typedef struct { int k; int data; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].data;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
module top;
  import a::*;
  A o;
endmodule
