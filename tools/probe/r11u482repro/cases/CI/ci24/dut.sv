// § cloneFixArrAggElemShared482 (class out-of-body method, a chain a then t)
package u;
  typedef union { int k; int data; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2];
    acc[1].k = n;
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top;
  import a::*; import t::*;
  A o; T p;
endmodule
