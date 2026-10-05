// § pkgAliasOfKwTd250
// alias-of-keyword typedefs as a module parameter type, a package localparam type, a package function return and an unsigned / integer / shortreal / realtime target
package p;
  typedef int unsigned u_t;
  typedef u_t au_t;
  typedef integer g_t;
  typedef g_t ag_t;
  typedef shortreal s_t;
  typedef s_t as_t;
  typedef realtime r_t;
  typedef r_t ar_t;
  localparam au_t LP = 7;
  function automatic ag_t f(au_t x); return ag_t'(x) + LP; endfunction
endpackage
module top #(parameter p::au_t P = 3) (output logic [31:0] o);
  import p::*;
  ag_t g;
  as_t s;
  ar_t r;
  assign g = f(P);
  initial begin s = 1.0; r = 2.0; end
  assign o = g;
endmodule
