// § enumTdLastWriter214 — a package wildcard-imports the home package without using the enum; a second one uses it; no module imports
package p;
  typedef enum logic [1:0] {U0, U1} u_t;
  typedef u_t ALIAS_T;
endpackage
package qa;
  import p::*;
  localparam int KA = 3;
endpackage
package qb;
  import p::*;
  function automatic ALIAS_T f(int x); return ALIAS_T'(x); endfunction
endpackage
module top(output int o);
  import qb::*;
  assign o = int'(f(1));
endmodule
