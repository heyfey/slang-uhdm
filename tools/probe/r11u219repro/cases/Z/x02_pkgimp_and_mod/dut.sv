// § enumTdLastWriter214 — a second package importing the alias and a module importing the home package: the module writes last
package p;
  typedef enum logic [1:0] {M0, M1, M2} mode_e;
  typedef mode_e ALIAS_T;
endpackage
package q;
  import p::*;
  function automatic int g(ALIAS_T v); return int'(v); endfunction
endpackage
module top(output int o);
  import p::*;
  import q::*;
  assign o = g(M2);
endmodule
