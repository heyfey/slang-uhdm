// r11v69 w2 — THE BASE IS NOT A MODULE PARAMETER PORT.  `caStructParamSetter55`
// accepts ANY `SymbolKind::Parameter` base, so a module LOCALPARAM, a PACKAGE
// localparam read QUALIFIED (`p::LIT.n`), and a $unit-scope one all reach the
// substitution inside a generate block.  The module-level twins say what golden
// does with each spelling, and the generate rows say whether the generate home
// answers the same.
package p;
  typedef struct packed { int unsigned n; logic [7:0] w; } cfg_t;
  localparam cfg_t LIT = '{n: 61, w: 8'h0C};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic a_i,
   output logic [31:0] t_lp, g_lp,
   output logic [31:0] t_pq, g_pq,
   output logic [31:0] t_par, g_par);

  localparam p::cfg_t MLP = '{n: 71, w: 8'h0D};   // module LOCALPARAM

  assign t_lp  = MLP.n;       // module-level twins
  assign t_pq  = p::LIT.n;
  assign t_par = CFG.n;

  if (1) begin : gq
    assign g_lp  = MLP.n;     // localparam base, generate home
    assign g_pq  = p::LIT.n;  // package-qualified base, generate home
    assign g_par = CFG.n;     // control
  end
endmodule
