// v11u84 v8 — LAW B x LAW A x LAW C in one package, plus the shapes t3 did
// not put on an EXPLICIT item: explicit + wildcard over the same home with an
// own declaration FIRST, an explicit item whose entry is an unpacked array
// (per-view vpiSize), and an explicit import of a name declared with `var`.
package xk1;
  typedef logic [7:0] xw_t;
  wire  xw_t  k_wtd;             // LAW A: def nt 1 / elab nt 36
  typedef xw_t xw2_t;
  wire  xw2_t k_wtd2;            // 2 hops: nt 1 both views
  typedef reg [7:0] xr_t;
  xr_t k_rv;                     // typedef reg: elab nt 48
  var logic [7:0] k_varkw = 8'd1;
  logic [7:0] k_ua [0:2];        // per-view size
  wire  [7:0] k_net;
endpackage

package xk2;                     // own decl FIRST, then explicit, then wildcard
  logic [7:0] k2_own;
  import xk1::k_wtd;
  import xk1::k_ua;
  import xk1::*;
  wire  [7:0] k2_net;
endpackage

package xk3;                     // wildcard then the SAME entry explicitly
  import xk1::*;
  import xk1::k_net;
endpackage

package xk4;                     // explicit over a `var`-keyword variable
  import xk1::k_varkw;
  import xk1::k_rv;
endpackage

module dut (output logic [31:0] o);
  import xk2::*;
  assign o = {24'd0, k2_own ^ k2_net};
endmodule
