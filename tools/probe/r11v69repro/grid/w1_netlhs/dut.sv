// r11v69 w1 — MODULE-BODY NET vs VARIABLE vs PORT as the gen-scope Lhs.
// `bindVariable` (CompileStmt.cpp:3089-3148) searches each scope's
// `Variables()` AND `Nets()`, so all three should fill `tps` and CLONE.  The
// patch's gate is `!genCaLhsGenLocal113`, whose namesake walk accepts
// `SymbolKind::Net` as well as `Variable` — if golden treats a NET differently
// the law fires where it must not.  Module-level twins beside every row.
package p;
  typedef struct packed { int unsigned n; logic [7:0] w; } cfg_t;
  localparam cfg_t LIT = '{n: 300, w: 8'hA5};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic a_i,
   output logic [31:0] o_p,           // module PORT target
   output logic [31:0] o_v, o_n, o_w,
   output logic [31:0] o_tv, o_tn);

  logic [31:0] mv;      // module-body VARIABLE
  wire  [31:0] mn;      // module-body NET
  wire  [7:0]  mw;      // module-body NET, NARROW (adjustSize visible)

  // module-level twins
  logic [31:0] tv;
  wire  [31:0] tn;
  assign tv = CFG.n;
  assign tn = CFG.n;
  assign o_tv = tv;
  assign o_tn = tn;

  if (1) begin : gb
    assign o_p = CFG.n;   // module PORT   -> tps from the port's internal sym
    assign mv  = CFG.n;   // module VAR
    assign mn  = CFG.n;   // module NET
    assign mw  = CFG.n;   // module NET, 8 bits -> 300 masks to 44
  end

  assign o_v = mv;
  assign o_n = mn;
  assign o_w = {24'd0, mw};
endmodule
