// r11v69 w7 — THE REGRESSION PROBE.  The law can only regress a cell where
// PRISTINE ALREADY AGREES with golden, i.e. where golden's `writeCont_assign`
// reducer REFUSES to fold and keeps a non-constant Rhs while the predicate
// still fires.  The predicate needs `structParamPattern55` to find a pattern,
// so the pattern is present and its MEMBER SETTERS are the hard ones: a system
// function, a user function call, `$bits`, a cast and an arithmetic chain.
// Our side folds every one through `ASTContext::tryEval`.  Module-level twins
// beside every generate row say what the landed pass-54 law already does.
package p;
  function automatic int unsigned f3(int unsigned x);
    return x + 3;
  endfunction
  typedef struct packed {
    int unsigned cl;    // $clog2
    int unsigned fc;    // user function call
    int unsigned bt;    // $bits
    int unsigned ar;    // arithmetic chain
    int unsigned cs;    // cast
  } cfg_t;
  localparam cfg_t LIT = '{ cl: $clog2(64), fc: f3(10), bt: $bits(int),
                            ar: (3 * 7) - 1, cs: int'(9) };
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i,
   output logic [31:0] t_cl, g_cl,
   output logic [31:0] t_fc, g_fc,
   output logic [31:0] t_bt, g_bt,
   output logic [31:0] t_ar, g_ar,
   output logic [31:0] t_cs, g_cs);

  assign t_cl = CFG.cl;
  assign t_fc = CFG.fc;
  assign t_bt = CFG.bt;
  assign t_ar = CFG.ar;
  assign t_cs = CFG.cs;

  if (1) begin : gu
    assign g_cl = CFG.cl;
    assign g_fc = CFG.fc;
    assign g_bt = CFG.bt;
    assign g_ar = CFG.ar;
    assign g_cs = CFG.cs;
  end
endmodule
