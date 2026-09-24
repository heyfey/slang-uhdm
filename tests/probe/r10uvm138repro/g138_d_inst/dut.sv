// r10uvm138 arm D — INSTANCE COUNT.  A package is compiled ONCE however many
// times its users are instantiated, so the folded cell must appear exactly
// once per listing and never once per instance.  Three instantiations of a
// module that calls the package function, plus a class instantiated three
// times inside it.
package p138d;
  typedef enum { D_A, D_B, D_C } ed_t;
  function ed_t d_ret();
    return D_B;
  endfunction
  class c138d;
    extern function ed_t d_oob();
  endclass
  function ed_t c138d::d_oob();
    return D_C;
  endfunction
endpackage

module sub138 #(parameter int K = 0) (output int o);
  import p138d::*;
  assign o = int'(d_ret()) + K;
endmodule

module m138d(output int a, output int b, output int c);
  sub138 #(.K(0)) u0 (.o(a));
  sub138 #(.K(1)) u1 (.o(b));
  sub138 #(.K(2)) u2 (.o(c));
endmodule
