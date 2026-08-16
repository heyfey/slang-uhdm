// r10earl47 GRID ARM A2 — the POSITION axis measured INSIDE A DESCENDANT GEN
// SCOPE, which arm B1 proved is the discriminator.
//
// B1's verdict: with the localparam and the use in the SAME gen scope golden
// keeps a ref_obj in every select position; with the use one gen scope DEEPER
// (a nested for-generate, or an if-generate — prim_keccak's `gen_others` is
// the latter) golden SUBSTITUTES the fold constant.  A2 repeats A1's whole
// position list one scope down, and repeats it for a MODULE-scope parameter
// (pinmux's MioPeriphHasSleepMode shape) beside it, so the two symbol classes
// are read off the same page.
//
// LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.
module a2_earl47;
  localparam int W  = 64;
  localparam int MP = 8;

  typedef logic [4:0][4:0][W-1:0] box_t;

  logic [255:0] d;
  box_t         bx;

  for (genvar x = 0; x < 3; x++) begin : gen_x
    localparam int LPA = 4 + x * 2;          // ARITH fold (INT)
    localparam int LPL = 8;                  // LITERAL fold (UINT)
    localparam int LPS = W - LPA;            // keccak's ShiftAmt shape (INT)

    // ---- the DESCENDANT scope: a nested for-generate --------------------
    for (genvar y = 0; y < 2; y++) begin : gen_y
      logic [63:0] n_ipsw, n_ipsb, n_ipswl, n_psl, n_psr, n_bit, n_op, n_rhs,
                   n_opinw, n_cat, n_2d, n_2db, n_mpw, n_mpb, n_mpcat, n_gvb;

      assign n_ipsw  = d[0 +: LPA];          // ips WIDTH      <- THE HEAD
      assign n_ipsb  = d[LPA +: 4];          // ips BASE
      assign n_ipswl = d[0 +: LPL];          // ips WIDTH, LITERAL-fold lp
      assign n_psl   = d[LPA : 0];           // part_select LEFT
      assign n_psr   = d[31 : LPA];          // part_select RIGHT
      assign n_bit   = d[LPA];               // bit_select INDEX
      assign n_op    = LPA + 1;              // operation OPERAND
      assign n_rhs   = LPA;                  // bare RHS
      assign n_opinw = d[0 +: LPA + 1];      // ips WIDTH holding an OPERATION
      assign n_cat   = {LPA[3:0], 1'b1};     // CONCAT operand (pinmux shape)
      assign n_2d    = bx[x][y][0 +: LPS];   // KECCAK: var_select + ips WIDTH
      assign n_2db   = bx[x][y][LPS +: 4];   // KECCAK: var_select + ips BASE

      // MODULE-scope parameter CONTROLS, same positions, same scope depth
      assign n_mpw   = d[0 +: MP];
      assign n_mpb   = d[MP +: 4];
      assign n_mpcat = {MP[3:0], 1'b1};
      // GENVAR control (the parent scope's genvar, read one scope down)
      assign n_gvb   = d[x +: 4];
    end

    // ---- the DESCENDANT scope: an if-generate (prim_keccak's gen_others) -
    if (x > 0) begin : gen_if
      logic [63:0] f_ipsw, f_ipsb;
      assign f_ipsw = d[0 +: LPA];
      assign f_ipsb = d[LPA +: 4];
    end
  end
endmodule
