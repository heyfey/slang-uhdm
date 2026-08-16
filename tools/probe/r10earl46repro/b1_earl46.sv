// r10earl46 GRID ARM B1 — the DISCRIMINATOR arm.
//
// a1_earl46.sv established the OPERATOR SET and showed the declared type is
// irrelevant.  This arm answers the ONE question that decides the SHAPE of the
// patch: is the gen-scope fold's signedness decided by
//
//   (V) a VISIT — "a Multiply/Divide/Power appears ANYWHERE in the init tree,
//       except under an explicit cast" (what ModuleEmit does today), or
//   (S) a STRUCTURAL walk — "the TOP operator mints a signed SValue, `+`
//       propagates from either operand, and EVERY OTHER operator RESETS"
//       (what ParamEmit's srlgArithFoldSigned and ExprEmit's isIntEncoded do,
//       and what UHDM's ExprEval actually implements)?
//
// (V) and (S) are indistinguishable on a1's rows.  They disagree exactly when
// a signed-minting operator sits UNDER a non-arithmetic one: an index, a
// shift, a bitwise op, a ternary, a call argument, a concat.  Every row below
// is such a cell, and choosing (S) without measuring these would silently
// re-encode them.
//
// Every value is NON-NEGATIVE in all five instances, so `negSib9` is off on
// every row.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
module b1_earl46;
  localparam int W = 64;
  localparam int ARR [5] = '{0, 36, 3, 105, 210};
  localparam int MOD_MOD = ARR[3] % W;   // 41, module scope, golden INT
  localparam int MOD_SEL = ARR[1];       // 36, module scope, golden UINT

  for (genvar x = 0; x < 5; x++) begin : gen_x
    // --- signed-minting operator UNDER a non-arithmetic one ---------------
    localparam int IDXMUL = ARR[x*1];              // * under an INDEX
    localparam int IDXMOD = ARR[(x+4) % 5];        // % under an INDEX
    localparam int SHL    = (ARR[x] % W) << 1;     // % under <<
    localparam int ANDM   = (ARR[x] % W) & 255;    // % under &
    localparam int ORM    = (ARR[x] * 2) | 1;      // * under |
    localparam int TERNM  = (x > 0) ? (ARR[x] % W) : 3;  // % under ?:
    localparam int TERNU  = (x > 0) ? (ARR[x] * 2) : 3;  // * under ?:
    localparam int FCALL  = $clog2(ARR[x] * 2 + 1);      // * under a call
    localparam int CONCM  = {2'b0, 6'(ARR[x] % W)};      // % under a concat
    localparam int LSHM   = 1 << (ARR[x] % 4);     // % in the SHIFT AMOUNT

    // --- propagation through a REF -----------------------------------------
    localparam int MODREF = MOD_MOD + 1;   // + over a MODULE-scope INT fold
    localparam int SELREF = MOD_SEL + 1;   // + over a MODULE-scope UINT fold

    // --- `-` reached through `+`, and `-` at the top -----------------------
    localparam int SUBADD = (ARR[x] - 0) + 1;
    localparam int ADDSUB = (ARR[x] + 1) - 0;

    // --- what exactly does an EXPLICIT cast seal? --------------------------
    localparam int CASTMUL = 32'(x) * 2;            // * OUTSIDE the cast
    localparam int CASTADD = 32'(ARR[x] % W) + 1;   // + outside, % sealed
    localparam int MULCAST = 32'(ARR[x] * 2);       // whole tree sealed

    // --- unary ops over a signed-minting subtree ---------------------------
    localparam int UPLUS  = +(ARR[x] % W);
    localparam int UNOTL  = !(ARR[x] % W);          // logical, 1 bit

    if (x >= 0) begin : gen_use
      wire [63:0] u0 = IDXMUL + SHL + ANDM + ORM + TERNM + TERNU;
      wire [63:0] u1 = FCALL + CONCM + LSHM + MODREF + SELREF;
      wire [63:0] u2 = SUBADD + ADDSUB + CASTMUL + CASTADD + MULCAST;
      wire [63:0] u3 = UPLUS + UNOTL + IDXMOD;
    end
  end
endmodule
