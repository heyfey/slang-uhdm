// § enumTdLastWriter214 — a program and a package import the home package, no module or interface does
package p;
  typedef enum logic [1:0] {P0, P1, P2} pe_t;
  typedef pe_t ALIAS_T;
endpackage
package q;
  import p::*;
  function automatic ALIAS_T f(ALIAS_T v); return v; endfunction
endpackage
program prg;
  import p::*;
  ALIAS_T pv;
  initial pv = P1;
endprogram
module top;
  prg u();
endmodule
