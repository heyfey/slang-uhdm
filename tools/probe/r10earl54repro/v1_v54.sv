// v54 VERIFIER ARM v1 — THE SHARED-SUBTREE ATTACK.
// foldConnReplNested54 walks a REFERENCED PARAMETER'S INITIALIZER to find
// replications, then REWRITES an operand slot of the emitted HighConn
// operation.  If the emitter SHARES one UHDM subtree between a parameter's own
// param_assign RHS (or a cont-assign / procedural use) and the conn HighConn,
// that rewrite mutates the OTHER owner too — and earl52-F2 says a parameter
// initializer replication must stay UNFOLDED.  census54.scan only reads port
// HighConns, so this class is invisible to the pass's own instruments.
package pkv1_54;
  parameter logic [7:0] REP8 = {8{1'b1}};
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pr_t;
  parameter pr_t PR = '{ hi: {4{1'b1}}, lo: 4'h0 };
endpackage

module snkv1_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module snkp_v1_54 (input pkv1_54::pr_t p, output [7:0] o);
  assign o = p.hi ^ p.lo;
endmodule

module v1_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  localparam logic [7:0] LREP = {8{1'b1}};
  logic [7:0] w1, w2, w3, w4, w5;
  // the package param as a CONN ACTUAL (initializer holds the replication)
  snkv1_54   u_pconn (.a(pkv1_54::REP8), .o(w1));
  // the struct param as a CONN ACTUAL (the clkmgr shape)
  snkp_v1_54 u_pat   (.p(pkv1_54::PR),   .o(w2));
  // the SAME params ALSO used in a cont-assign and a procedural block
  assign w3 = pkv1_54::REP8 ^ LREP;
  always_comb w4 = {4'h0, pkv1_54::PR.hi};
  // localparam as a conn actual
  snkv1_54   u_lconn (.a(LREP), .o(w5));
  assign q = w1 ^ w2 ^ w3 ^ w4 ^ w5;
endmodule
