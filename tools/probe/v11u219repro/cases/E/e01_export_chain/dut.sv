// § enumPkgWriterImportsType219 — an export chain: q imports and exports p::*, r imports only q::* and lists p's enum through the export, a module imports r
package p;
  typedef enum logic [1:0] {A0, A1, A2} e_t;
endpackage
package q;
  import p::*;
  export p::*;
  function automatic e_t qf(e_t v); return v; endfunction
endpackage
package r;
  import q::*;
  e_t rv;
endpackage
module top(output int o);
  import r::*;
  assign o = int'(rv);
endmodule
