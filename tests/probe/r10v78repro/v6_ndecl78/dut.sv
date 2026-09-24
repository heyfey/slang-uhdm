// r10v78 arm v6 — NET-DECLARATION ASSIGNMENTS and other cont_assign CARRIERS
// inside a gen scope, plus a BIND host and a gen scope reached through an
// interface instantiated in a gen scope.
interface v6if;
  logic [3:0] q;
endinterface
module v6bnd();
  localparam int BW = 6;
  logic [3:0] b_t;
  if (BW > 0) begin : g_b
    assign b_t = {BW{1'b1}};
  end
endmodule
module v6sub();
  localparam int TW = 6;
  logic [3:0] mb_t;
  if (TW > 0) begin : g6
    wire  [3:0] nd_nar = {TW{1'b1}};   // N1 NET-DECL-ASSIGN, gen-local net
    wire  [9:0] nd_wid = {TW{1'b1}};   // N2 NET-DECL-ASSIGN, wider
    logic [3:0] vd_nar = {TW{1'b1}};   // N3 VARIABLE initialiser (not a CA)
    assign mb_t = {TW{1'b1}};          // N4 control: module-body Lhs
    v6if u_gi();                       // an interface INSIDE a gen scope
    assign u_gi.q = {TW{1'b1}};        // N5 hier_path into that interface
  end
endmodule
module v6;
  v6sub u_s();
  v6bnd u_b();
endmodule
