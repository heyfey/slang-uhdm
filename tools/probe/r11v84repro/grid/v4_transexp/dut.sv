// v11u84 v4 — THE EXPLICIT CLONE CARRIED ON (LAW B inside impVars9).
// ta1 declares; ta2 EXPLICITLY imports one entry; ta3 WILDCARD-imports ta2, so
// golden's ta3 listing must carry ta2's clone (the same pointer again).  ta4
// imports ta2 explicitly by ta2's OWN name (legal: ta2 declares t_own).
package ta1;
  wire  [7:0] t_net;
  logic [7:0] t_var = 8'd7;
  typedef logic [7:0] tw_t;
  wire  tw_t  t_wtd;             // the 1-hop typedef net: LAW A's surface
  logic [7:0] t_uarr [0:1];
endpackage

package ta2;
  import ta1::t_wtd;             // an explicit clone that LAW A also touches
  import ta1::t_uarr;
  wire  [7:0] t_own;
endpackage

package ta3;
  import ta2::*;                 // carries ta2's clones AND ta2's own entry
  logic [7:0] t3_own;
endpackage

package ta4;
  import ta2::t_own;             // an explicit item over ta2's OWN entry
  wire  [7:0] t4_own;
endpackage

module dut (output logic [31:0] o);
  import ta3::*;
  import ta2::t_own;
  assign o = {24'd0, t3_own ^ t_own};
endmodule
