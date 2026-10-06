// § cloneLoopVarHomeDeclTs259 (two classes with a same-named out-of-body method over formals of two typedefs)
package p;
  typedef bit unsigned [63:0] addr_t;
  typedef bit unsigned [15:0] w_t;
  class c1;
    extern function int f(ref addr_t a[]);
  endclass
  class c2;
    extern function int f(ref w_t a[]);
  endclass
  function int c1::f(ref addr_t a[]);
    foreach (a[i]) a[i] = 0;
    return 0;
  endfunction
  function int c2::f(ref w_t a[]);
    foreach (a[i]) a[i] = 0;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
