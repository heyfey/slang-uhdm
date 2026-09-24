// r10earl38 — a1_chain.sv — THE WITNESS AND ITS AXES.
//
// The target is padring.sv:126 `logic unused_out, unused_oe;` declared inside
// `end else if (ConnectMioIn[k]) begin : gen_mio_input`, itself inside
// `for (genvar k = ...) begin : gen_mio_pads`.  Golden's DEF-view named_begin
// carries TWO Rhs-less `assignment` statements (one per DECLARATOR, spanned at
// the NAME); ours carries none.
//
// Every cell below is a DEF-view generate branch holding the SAME declaration
// shape.  The axes crossed:
//   * POSITION IN THE CHAIN  — the `if` block / 1st `else if` / 2nd `else if`
//     (padring's own position) / 3rd `else if` / the final `else`
//   * ENCLOSING CONSTRUCT    — inside a gen-for / at module level / inside a
//     nested gen-for / a plain (no-else) gen-if / a two-branch if-else
//   * DECLARATOR COUNT       — one vs two vs three on one declaration
//   * WRITTEN INITIALISER    — bare vs `= <const>`
//   * TYPE                   — scalar `logic` / ranged `logic [W-1:0]` /
//     `integer` / `int` / unpacked array
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

module top38 #(
    parameter int unsigned NP = 4,
    parameter int unsigned WD = 3
) (
    input  logic [NP-1:0] a_i,
    output logic [NP-1:0] z_o
);

  localparam bit [NP-1:0] SelA = 4'b0001;
  localparam bit [NP-1:0] SelB = 4'b0010;

  //////////////////////////////////////////////////////////////////////////
  // W — THE WITNESS.  padring's exact shape: gen-for > 4-branch else-if
  // chain, every branch holding a multi-declarator bare `logic` declaration.
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_w
    if (SelA[k] && SelB[k]) begin : gen_w1          // the `if` block
      logic w1_out, w1_oe;
      assign w1_out = a_i[k];
      assign w1_oe  = a_i[k];
    end else if (SelB[k]) begin : gen_w2            // 1st `else if`
      logic w2_out, w2_oe;
      assign w2_out = a_i[k];
      assign w2_oe  = a_i[k];
    end else if (SelA[k]) begin : gen_w3            // 2nd `else if` — PADRING
      logic w3_out, w3_oe;
      assign w3_out = a_i[k];
      assign w3_oe  = a_i[k];
    end else begin : gen_w4                         // the final `else`
      logic w4_out, w4_oe;
      logic [WD-1:0] w4_attr;
      assign w4_out  = a_i[k];
      assign w4_oe   = a_i[k];
      assign w4_attr = {WD{a_i[k]}};
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // X — a FIVE-branch chain: does the 3rd `else if` (one deeper than
  // padring's) behave the same as the 2nd?
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_x
    if (SelA[k] && SelB[k]) begin : gen_x1
      logic x1_a, x1_b;
    end else if (SelB[k]) begin : gen_x2
      logic x2_a, x2_b;
    end else if (SelA[k]) begin : gen_x3
      logic x3_a, x3_b;
    end else if (k == 2) begin : gen_x4
      logic x4_a, x4_b;
    end else begin : gen_x5
      logic x5_a, x5_b;
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // Y — the CHAIN-vs-PLAIN-ELSE fence.  `if / else` (two branches, the else
  // clause is a GenerateBlock) against `if / else if / else` (the else clause
  // is an IfGenerate).  Same enclosing gen-for, same declaration.
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_y
    if (SelA[k]) begin : gen_y1                     // plain if/else, THEN
      logic y1_a, y1_b;
    end else begin : gen_y2                         // plain if/else, ELSE
      logic y2_a, y2_b;
    end
  end

  for (genvar k = 0; k < NP; k++) begin : gen_z
    if (SelA[k]) begin : gen_z1                     // no else at all
      logic z1_a, z1_b;
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // M — the MODULE-LEVEL control: the same 4-branch chain with NO enclosing
  // gen-for.  (r5p_gpr gen_default's shape — the `!astBlock -> body.members()`
  // fallback already serves this one.)
  //////////////////////////////////////////////////////////////////////////
  if (SelA[0] && SelB[0]) begin : gen_m1
    logic m1_out, m1_oe;
  end else if (SelB[0]) begin : gen_m2
    logic m2_out, m2_oe;
  end else if (SelA[0]) begin : gen_m3
    logic m3_out, m3_oe;
  end else begin : gen_m4
    logic m4_out, m4_oe;
  end

  //////////////////////////////////////////////////////////////////////////
  // D — DECLARATOR COUNT and WRITTEN INITIALISER, in the padring position
  // (2nd `else if` of a chain inside a gen-for).
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_d
    if (SelA[k] && SelB[k]) begin : gen_d1
      logic d1_only;                                // ONE declarator
    end else if (SelB[k]) begin : gen_d2
      logic d2_a, d2_b, d2_c;                       // THREE declarators
    end else if (SelA[k]) begin : gen_d3
      logic d3_bare;                                // one, bare
      logic d3_init = 1'b0;                         // one, WRITTEN INIT
      logic d3_x, d3_y = 1'b1;                      // MIXED bare + init
    end else begin : gen_d4
      logic [WD-1:0] d4_vec, d4_vec2;               // RANGED logic
      integer        d4_int, d4_int2;               // integer
      int            d4_i32;                        // int
      logic          d4_arr [0:1];                  // unpacked array
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // N — a chain nested inside ANOTHER chain's branch, and a gen-for nested
  // inside a chain branch: does the scope thread through two levels?
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_n
    if (SelA[k] && SelB[k]) begin : gen_n1
      logic n1_a, n1_b;
    end else if (SelA[k]) begin : gen_n2
      logic n2_a, n2_b;
      if (SelB[0]) begin : gen_n2a                  // nested if INSIDE a chain
        logic n2a_a, n2a_b;
      end else if (SelA[0]) begin : gen_n2b         // nested CHAIN inside it
        logic n2b_a, n2b_b;
      end else begin : gen_n2c
        logic n2c_a, n2c_b;
      end
      for (genvar j = 0; j < 2; j++) begin : gen_n2f  // nested gen-for
        logic n2f_a, n2f_b;
      end
    end else begin : gen_n3
      logic n3_a, n3_b;
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // P — the gen-for body's OWN declaration (no if at all) and an
  // unconditional named generate block: the already-served positions.
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_p
    logic p_a, p_b;
    assign p_a = a_i[k];
  end

  assign z_o = a_i;

endmodule
