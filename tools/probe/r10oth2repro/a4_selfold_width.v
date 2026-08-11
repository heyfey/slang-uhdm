// r10oth2 ARM A4 -- DIRECTION A, second head.
//
// With § srlgUnbasedReduceBail landed, BlackParrotComplex's remaining cmp head
// is `parameter A = A3[2];` in module `bottom` (dut.sv:82):
//     LHS(golden)  constant UINT:3 vpiSize:64  vpiConstType:9
//     RHS(ours)    constant UINT:3 vpiSize:32  vpiConstType:9
// i.e. the existing § elabRefFold9 rule ("an ELAB fold whose source is a
// parameter reference -- bare, qualified or SELECTED -- is sized at the reading
// param's own TYPE width") is too wide: it claims the SELECT case, and golden
// keeps 64 when the selected base is an UNPACKED ARRAY parameter.
//
// This file varies ONLY the BASE the select reads, so the width rule can be
// read off golden's ELAB view (uhdmtopModules) one row at a time.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
module t ();
  parameter int         UA[0:2] = {1, 2, 3};     // unpacked array of int
  // (an UNTYPED unpacked-array parameter is a slang hard error --
  //  "unpacked array parameter requires explicit data type" -- so the
  //  untyped-unpacked cell of this grid does not exist in the language.)
  parameter logic [7:0] PV      = 8'hAB;         // packed vector
  parameter       [7:0] PU      = 8'hAB;         // packed vector, untyped
  parameter bit [1:0][2:0] PA   = {3'b011, 3'b101};  // multi-dim packed
  parameter int         NB      = 7;             // plain scalar
  parameter             NC      = 7;             // plain scalar, untyped

  // ---- ELEMENT SELECT off each base ---------------------------------------
  localparam s_ua = UA[2];   // the BlackParrotComplex shape
  localparam s_pv = PV[3];
  localparam s_pu = PU[3];
  localparam s_pa = PA[0];

  // ---- RANGE SELECT --------------------------------------------------------
  localparam r_pv = PV[3:0];
  localparam r_pu = PU[3:0];

  // ---- BARE reference (the rule's original, unquestioned half) ------------
  localparam b_nb = NB;
  localparam b_nc = NC;
  localparam b_pv = PV;

  // ---- ARITHMETIC over a select (does the width survive one operator?) ----
  localparam a_ua = UA[2] + 0;
  localparam a_pv = PV[3] + 0;

  // ---- the OTHER SPELLING of the unpacked-array element: SIZED elements.
  // If golden's width tracked the ELEMENT LITERAL's own size these would read 8
  // and 32; if it is simply "an unpacked-array element select keeps 64" they
  // read 64 like UA does.  This is the cell that decides which rule to write.
  parameter logic [7:0] UC[0:2] = {8'h1, 8'h2, 8'h3};
  parameter int         UD[0:2] = {32'd1, 32'd2, 32'd3};
  localparam s_uc = UC[2];
  localparam s_ud = UD[2];

  // ---- and the OTHER BRACE: an assignment PATTERN initializer.
  // BlackParrotComplex writes BOTH spellings six lines apart -- module `middle`
  // uses `'{1,2,3}` (dut.sv:69) and module `bottom` uses `{1,2,3}` (dut.sv:81)
  // -- and golden's two elab folds DISAGREE (32 vs 64).  This row is the
  // in-arm control for that.
  parameter int         UP[0:2] = '{1, 2, 3};
  localparam s_up = UP[2];

  initial $display("%d %d %d %d %d %d %d %d %d %d %d %d %d",
                   s_ua, s_pv, s_pu, s_pa, r_pv, r_pu,
                   b_nb, b_nc, b_pv, a_ua, a_pv, s_uc, s_ud, s_up);
endmodule
