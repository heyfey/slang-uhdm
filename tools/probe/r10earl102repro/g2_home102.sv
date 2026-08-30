// r10earl102 g2_home102 -- WHERE the unpacked-array parameter LIVES, with one
// and the same bound form (`[0:N-1]`, the head's).
//
// Homes: a PACKAGE parameter imported into a module; a MODULE parameter sized
// by a module localparam; a MODULE parameter sized by an OVERRIDDEN parameter
// (the param_array_wildcard control that must NOT fold); a GEN-SCOPE
// localparam; an INTERFACE parameter; and THREE INSTANCES of one module, so a
// per-instance fold is visible as three cells of one span.
package p2h102;
  parameter int PN = 2;
  parameter int PPKG [0:PN-1] = '{1, 0};
endpackage

interface if2h102;
  parameter int IN = 3;
  parameter int IARR [0:IN-1] = '{1, 0, 2};
  logic x;
endinterface

module m2sub102 #(
  parameter int OVN = 2,                       // OVERRIDABLE: must stay symbolic
  parameter int OVARR [0:OVN-1] = '{1, 0}
) (
  output int o
);
  import p2h102::*;
  localparam int LN = 3;
  localparam int LARR  [0:LN-1] = '{1, 0, 2};  // module localparam, local size
  parameter  int MARR  [0:LN-1] = '{2, 1, 0};  // module parameter, local size
  if (1) begin : g
    localparam int GN = 2;
    localparam int GARR [0:GN-1] = '{1, 0};    // gen-scope localparam
    logic signed [31:0] gw;
    assign gw = GARR[0];
  end
  assign o = PPKG[0] + OVARR[0] + LARR[0] + MARR[0] + g.gw;
endmodule

module g2_home102 (output int o);
  if2h102 ifc ();
  int a, b, c;
  m2sub102            u0 (.o(a));               // default OVN
  m2sub102 #(.OVN(3), .OVARR('{1,0,2})) u1 (.o(b)); // overridden
  m2sub102            u2 (.o(c));               // a third instance of one span
  assign o = a + b + c + ifc.IARR[0];
endmodule
