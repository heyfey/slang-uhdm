// r10earl47 GRID ARM A1 — the GEN-SCOPE LOCALPARAM USE-SITE SUBSTITUTION,
// POSITION axis.
//
// THE QUESTION.  Earlgrey's prim_keccak.sv:65 is
//     assign rho_data[x][y][W-1:0] = {theta_data[x][y][0+:ShiftAmt],
//                                     theta_data[x][y][ShiftAmt+:Offset]};
// inside a doubly-nested for-generate whose INNER gen scope declares
//     localparam int Offset   = RhoOffset[x][y] % W;
//     localparam int ShiftAmt = W - Offset;
// Golden SUBSTITUTES those localparams' folded constants at the USE sites —
// the constant carries the USE span, claims the localparam's own param_assign
// as vpiParent, and binds a gen-scope-named ref_typespec — while we emit a
// plain ref_obj.  We ALREADY do exactly that substitution for a gen CA whose
// whole RHS is the bare localparam (the genLpConst SHARE) and for a hier-path
// INDEX (gen_test4 foo[PREV].temp).
//
// So the question is not WHETHER golden substitutes — it is WHERE.  This arm
// puts ONE gen-scope localparam in TWELVE different syntactic positions and
// two control symbols (a GENVAR and a MODULE-scope parameter) in the same
// positions, and measures the answer against Surelog cell for cell.
//
// LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.
module a1_earl47;
  localparam int W  = 64;
  localparam int MP = 8;                       // MODULE-scope param CONTROL

  typedef logic [4:0][4:0][W-1:0] box_t;       // prim_keccak's box_t

  logic [255:0] d;
  box_t         bx;

  for (genvar x = 0; x < 3; x++) begin : gen_x
    localparam int LPA = 4 + x * 2;            // ARITH fold  (INT, § 46: `*`)
    localparam int LPL = 8;                    // LITERAL fold (UINT)
    localparam int LPS = W - LPA;              // keccak's ShiftAmt shape (INT)

    logic [63:0] r_ipsw, r_ipsb, r_ipswl, r_psl, r_psr, r_bit, r_op, r_rhs,
                 r_opinw, r_gvb, r_mpw, r_mpop, r_2d, r_2db, r_catop;

    // ---- POSITION AXIS, one gen-scope localparam ------------------------
    assign r_ipsw   = d[0 +: LPA];         // ips WIDTH        <- THE HEAD
    assign r_ipsb   = d[LPA +: 4];         // ips BASE
    assign r_ipswl  = d[0 +: LPL];         // ips WIDTH, LITERAL-fold lp
    assign r_psl    = d[LPA : 0];          // part_select LEFT range
    assign r_psr    = d[31 : LPA];         // part_select RIGHT range
    assign r_bit    = d[LPA];              // bit_select INDEX
    assign r_op     = LPA + 1;             // operation OPERAND
    assign r_rhs    = LPA;                 // bare RHS (the EXISTING share)
    assign r_opinw  = d[0 +: LPA + 1];     // ips WIDTH holding an OPERATION
    assign r_catop  = {d[LPA-1 : 0], 1'b1};// part_select bound under a CONCAT

    // ---- CONTROLS: a GENVAR and a MODULE-scope parameter, same positions -
    assign r_gvb    = d[x +: 4];           // ips BASE = GENVAR
    assign r_mpw    = d[0 +: MP];          // ips WIDTH = MODULE param
    assign r_mpop   = MP + 1;              // operand   = MODULE param

    // ---- THE KECCAK SHAPE: var_select (2 indices) + trailing ips --------
    assign r_2d     = bx[x][1][0 +: LPS];  // ips WIDTH under a var_select
    assign r_2db    = bx[x][1][LPS +: 4];  // ips BASE  under a var_select
  end
endmodule
