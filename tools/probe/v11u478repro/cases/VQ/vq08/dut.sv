// § aliasCopyParamUnnamed478 (a specialization as a function local in a package function)
package a;
  class A #(int W = 1);
    typedef A #(W) this_t;
    int x;
  endclass
  typedef A #(5) A_t;
  function automatic int f();
    A_t h;
    h = new;
    return h.x;
  endfunction
endpackage
package b;
  import a::*;
  class B; function int g(); return f(); endfunction endclass
endpackage
module top; import b::*; B o; endmodule
