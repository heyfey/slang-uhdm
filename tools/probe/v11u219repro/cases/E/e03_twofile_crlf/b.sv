// § enumTdLastWriter214 — the importing package in a CRLF file
package q;
  import p::*;
  function automatic ALIAS_T g(ALIAS_T v); return v; endfunction
endpackage
module top(output int o);
  import q::*;
  import p::*;
  assign o = int'(g(K2));
endmodule
