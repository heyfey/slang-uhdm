// § enumTdLastWriter214 — the enum and its alias declared through a macro body in the home package; an interface and a package import it
`define MKENUM(N, A) \
  typedef enum logic [1:0] {N``_0, N``_1, N``_2} N``_t; \
  typedef N``_t A;
package p;
  `MKENUM(mc, ALIAS_T)
endpackage
package q;
  import p::*;
  function automatic ALIAS_T g(ALIAS_T v); return v; endfunction
endpackage
interface ifc;
  import p::*;
  ALIAS_T iv;
endinterface
module top(output int o);
  import q::*;
  ifc u();
  assign o = 0;
endmodule
