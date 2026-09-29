// § enumPkgWriterImportsType219 — a package whose only import of the home package is local to a function
package p;
  typedef enum logic [1:0] {L0, L1, L2} l_t;
endpackage
package q;
  function automatic int f(int x);
    import p::*;
    l_t v;
    v = l_t'(x);
    return int'(v);
  endfunction
endpackage
module top(output int o);
  import q::*;
  assign o = f(2);
endmodule
