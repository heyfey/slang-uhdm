// r10earl30 arm g2_origin.sv — AXIS (a): what the folded constant was FOLDED
// FROM.  The CONTEXT is held FIXED at the witness's context (the right operand
// of an `==` comparison inside an if), so any difference between cells here is
// attributable to the ORIGIN alone.
//
// This arm is also the OVER-FIRE CENSUS for the shipped rule: the corpus already
// contains thousands of vpiConstType:9 constants that MATCH golden, and the
// cells in here that read 9 on BOTH sides are the ones a blanket 9->7 destroys.
package p2;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;      // the witness's enum shape
  localparam int          PI  = 3;                  // plain package parameter
  localparam logic [2:0]  PL  = 3'd3;               // sized package parameter
  localparam e_t          PE  = E1;                 // ENUM-TYPED package parameter
endpackage

module g2_origin (input logic [2:0] q, input logic [31:0] w, output logic [15:0] o);

  typedef enum logic [2:0] { L0, L1, L2 } le_t;     // MODULE-scope enum
  localparam int         MI = 3;                    // module localparam
  localparam le_t        ME = L1;                   // enum-typed module localparam
  localparam int         MD = 12 / 4;               // division fold -> INT family
  localparam int         MA = 1 + 2;                // arithmetic fold

  logic [15:0] r;

  always_comb begin
    r = 16'd0;
    // c1  PACKAGE enum literal, member value 0          (THE WITNESS)
    if (q == p2::E0) r[0]  = 1'b1;
    // c2  PACKAGE enum literal, member value != 0
    if (q == p2::E1) r[1]  = 1'b1;
    // c3  LOCAL (module-scope) enum literal, value 0
    if (q == L0)     r[2]  = 1'b1;
    // c4  LOCAL enum literal, value != 0
    if (q == L1)     r[3]  = 1'b1;
    // c5  plain PACKAGE parameter (int)
    if (q == p2::PI) r[4]  = 1'b1;
    // c6  sized PACKAGE parameter (logic [2:0])
    if (q == p2::PL) r[5]  = 1'b1;
    // c7  ENUM-TYPED PACKAGE parameter
    if (q == p2::PE) r[6]  = 1'b1;
    // c8  plain MODULE localparam (int)
    if (q == MI)     r[7]  = 1'b1;
    // c9  ENUM-TYPED MODULE localparam
    if (q == ME)     r[8]  = 1'b1;
    // c10 DIVISION fold (our isIntEncoded already says INT here)
    if (q == MD)     r[9]  = 1'b1;
    // c11 ARITHMETIC fold
    if (q == MA)     r[10] = 1'b1;
    // c12 a plain INTEGER LITERAL operand — the never-touch control
    if (q == 3)      r[11] = 1'b1;
    // c13 a SIZED literal operand — the never-touch control
    if (q == 3'd3)   r[12] = 1'b1;
    // c14 CAST of a literal to the package enum type
    if (q == p2::e_t'(1)) r[13] = 1'b1;
    // c15 a $bits() system-call fold
    if (w == $bits(p2::e_t)) r[14] = 1'b1;
  end

  assign o = r;

  // c16 GENVAR-folded comparison operand, inside a generate for
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      logic gh;
      always_comb gh = (q == gi);
    end
  endgenerate

endmodule
