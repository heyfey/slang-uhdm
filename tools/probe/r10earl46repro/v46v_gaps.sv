// r10earl46 VERIFIER probe — the cells the implementer's a1/b1 arms never put
// on the table.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
//  G1 NOTB   `~` over a %-fold.  The in-code comment says "`!` and `~` RESET"
//            and cites b1's UNOTL, which is `!`.  `~` was NEVER measured.
//  G2 SHR    `>>`  over a *-fold   (b1 has `<<` only)
//  G3 ASHR   `>>>` over a *-fold   (arithmetic shift, never measured)
//  G4 PKGREF `+` over a PACKAGE-scope param ref (b1's MODREF is module scope)
//  G5 NEGSEL a SELECT init in a gen array with a NEGATIVE sibling: negSib9
//            fires on the CONSTANT, the law does not, and the PARAMETER value
//            arm has no negSib9 -> the two carriers can disagree.  a1's NEG row
//            cannot show this because `-` mints on its own merits.
//  G6 BIGMUL a signed-minting op whose 32-bit result has the MSB SET.  The
//            digits half (§ genLpFoldSignedIntReadsBitsSigned46) was measured
//            ONLY at -1 (int_types).
//  G7 CMPM   a comparison over a %-fold (resets by construction, unmeasured)
//  G8 ANDL   `&&` over a %-fold (unmeasured)
//  G9 CHAIN3 a 3-deep `+`-over-REF chain (depth cap is unmeasured)
package p46v;
  localparam int PKGMOD = 105 % 64;   // 41
endpackage

module v46v_gaps;
  localparam int W = 64;
  localparam int ARR    [5] = '{0, 36, 3, 105, 210};
  localparam int NEGARR [5] = '{-1, 36, 3, 105, 210};
  localparam int MOD_MOD = ARR[3] % W;         // 41, module scope, golden INT

  for (genvar x = 0; x < 5; x++) begin : gen_x
    localparam int NOTB   = (~(ARR[x] % W)) & 255;
    localparam int SHR    = (ARR[x] * 2) >> 1;
    localparam int ASHR   = (ARR[x] * 2) >>> 1;
    localparam int PKGREF = p46v::PKGMOD + 1;
    localparam int NEGSEL = NEGARR[x];
    localparam int unsigned BIGMUL = 32'hC0000000 * 1;
    localparam int CMPM   = (ARR[x] % W) > 0;
    localparam int ANDL   = (ARR[x] % W) && 1;
    localparam int CHAIN1 = MOD_MOD + 0;
    localparam int CHAIN2 = CHAIN1  + 0;
    localparam int CHAIN3 = CHAIN2  + 0;

    if (x >= 0) begin : gen_use
      wire [63:0] v0 = NOTB + SHR + ASHR + PKGREF;
      wire [63:0] v1 = NEGSEL + BIGMUL + CMPM + ANDL;
      wire [63:0] v2 = CHAIN1 + CHAIN2 + CHAIN3;
    end
  end
endmodule
