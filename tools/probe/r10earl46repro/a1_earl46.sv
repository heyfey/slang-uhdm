// r10earl46 GRID ARM A1 — the GEN-SCOPE LOCALPARAM FOLD ENCODING matrix.
//
// THE QUESTION.  Earlgrey's prim_keccak.sv:60 is
//     localparam int Offset = RhoOffset[x][y] % W;
// inside a doubly-nested for-generate, and golden encodes its param_assign
// constant INT:0 / vpiConstType 7 where we write UINT:0 / vpiConstType 9.
// ModuleEmit's gen-scope fold decides that encoding with a visitor that lists
// exactly {Multiply, Divide, Power}.  `%` is absent.  Two OTHER encoding laws
// in this codebase DO answer `%`:
//   * ParamEmit's  srlgArithFoldSigned  (§ impModFoldSigned) — {-, *, /, %},
//     unary minus, and `+` PROPAGATES;
//   * ExprEmit's   isIntEncoded         — {/, %, signed **}, both operands
//     propagate.
// They disagree with each other on `-` and on `*`, so NEITHER can be assumed
// for the gen-scope carrier.  This arm measures the gen-scope carrier itself,
// cell for cell, against Surelog.
//
// EVERY value below is NON-NEGATIVE in EVERY one of the five instances, so the
// `negSib9` arm (a negative sibling forces INT on the whole gen array) is OFF
// on every row and cannot be confused with the operator law.  Row NEG is the
// deliberate exception that proves that arm still fires.
//
// LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.
module a1_earl46;
  localparam int W = 64;
  localparam int ARR [5] = '{0, 36, 3, 105, 210};   // %64 -> 0,36,3,41,18

  // MODULE-SCOPE controls (a DIFFERENT carrier: ParamEmit, not ModuleEmit's
  // gen-scope fold).  If these move, the patch reached the wrong emitter.
  localparam int MOD_MOD = ARR[3] % W;   // 41
  localparam int MOD_SUB = W - ARR[1];   // 28
  localparam int MOD_ADD = W + ARR[1];   // 100
  localparam int MOD_SEL = ARR[1];       // 36

  for (genvar x = 0; x < 5; x++) begin : gen_x
    // ---- OPERATOR AXIS, declared type `int` throughout -------------------
    localparam int A_MOD  = ARR[x] % W;          // THE HEAD's shape
    localparam int B_DIV  = (ARR[x] + 1) / 2;    // known INT (mulDiv9)
    localparam int C_MUL  = ARR[x] * 2;          // known INT (mulDiv9)
    localparam int D_SUB  = W - A_MOD;           // prim_keccak's ShiftAmt
    localparam int E_SUB2 = 256 - ARR[x];        // plain subtract, no sibling
    localparam int F_ADD  = W + ARR[x];          // known UINT
    localparam int G_SEL  = ARR[x];              // known UINT
    localparam int H_GMOD = x % 3;               // `%` over a GENVAR
    localparam int I_KMOD = 7 % 3;               // `%` over LITERALS only
    localparam int J_PROP = A_MOD + 1;           // `+` over a %-folded sibling
    localparam int K_MODM = (ARR[x] % W) * 2;    // % nested under *
    localparam int L_CAST = 32'(ARR[x] % W);     // EXPLICIT CAST seals?
    localparam int M_POW  = 2 ** (x + 1);        // known INT (mulDiv9)
    localparam int N_UMIN = -(0 - ARR[x]);       // unary minus, value >= 0

    // ---- DECLARED-TYPE AXIS, init fixed at `ARR[x] % W` ------------------
    localparam int unsigned  T_IU = ARR[x] % W;
    localparam logic [31:0]  T_LG = ARR[x] % W;
    localparam bit [7:0]     T_BT = ARR[x] % W;
    localparam byte          T_BY = ARR[x] % W;
    localparam shortint      T_SI = ARR[x] % W;
    localparam integer       T_IG = ARR[x] % W;
    localparam               T_UN = ARR[x] % W;   // UNTYPED

    // ---- the negSib9 control: instance 0 is negative -> whole array INT --
    localparam int NEG = x - 1;

    if (A_MOD >= 0) begin : gen_use
      wire [63:0] w0 = A_MOD;
      wire [63:0] w1 = D_SUB;
      wire [63:0] w2 = T_UN;
      wire [63:0] w3 = NEG;
    end
  end
endmodule
