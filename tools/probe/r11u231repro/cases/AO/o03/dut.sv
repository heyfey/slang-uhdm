// § tfArgImportCloneFollowsIn231 — a package function writer after the out-of-body definition
package p;
  typedef enum {A0, A1, A2} e_t;
  class c1;
    extern function void f(e_t x);
  endclass
  function void c1::f(e_t x);
  endfunction
  function automatic int g(e_t z);
    return int'(z);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(output int o);
  assign o = p::g(p::A1);
endmodule
