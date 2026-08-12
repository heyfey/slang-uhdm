// r10earl30 VERIFIER arm v7 — THE EMPTY PRODUCT CELLS the implementer's grid
// skipped.  The shipped rule keys ONLY on the enum_const value's encoding
// prefix (`INT:` -> vpiIntConst 7).  Therefore the ONLY way it can OVER-FIRE is
// a shape where OUR enum_const value reads `INT:` but GOLDEN's folded constant
// reads a vpiConstType OTHER THAN 7 (either because golden's enum_const carries
// a DIFFERENT encoding there, or because golden derives the const type from
// something other than the value for that member form).
//
// g3_base covered: logic[2:0], logic[7:0], logic signed[2:0], bit[1:0], int,
// no-base, byte, based-init (3'd0), unsized-decimal-init (0 -> UINT:/64).
// IT DID NOT COVER ANY *UNSIGNED* INTEGER-ATOM BASE, nor a NEGATIVE member, nor
// a member whose value comes from an EXPRESSION, nor an implicit member that
// FOLLOWS an unsized-decimal member, nor unbased-unsized literals, nor a
// >32-bit value.  Those are this arm's cells.
package p7;
  parameter int PP = 5;

  // A1 — int UNSIGNED base.  The signed `int` base reads 7 in g3; an unsigned
  // atom base is the natural place for golden to switch to vpiUIntConst.
  typedef enum int unsigned { A0, A1 } a_t;
  // B — byte unsigned
  typedef enum byte unsigned { B0, B1 } b_t;
  // C — shortint unsigned
  typedef enum shortint unsigned { C0, C1 } c_t;
  // D — longint (64-bit signed)
  typedef enum longint { D0, D1 } d_t;
  // E — longint unsigned
  typedef enum longint unsigned { E0, E1 } e_t;
  // F — integer base
  typedef enum integer { F0, F1 } f_t;
  // G — NEGATIVE member of a signed base
  typedef enum int { G0 = -1, G1 = 1 } g_t;
  // H — implicit member IMMEDIATELY FOLLOWING an unsized-decimal member.
  //     H0 is the UINT:/64 negative control; H1 is implicit AFTER it.
  typedef enum logic [2:0] { H0 = 0, H1 } h_t;
  // I — member from a constant EXPRESSION
  typedef enum logic [7:0] { I0 = PP + 1, I1 = PP * 2 } i_t;
  // J — unbased unsized literals
  typedef enum logic [3:0] { J0 = '0, J1 = '1 } j_t;
  // K — signed based literal
  typedef enum logic signed [3:0] { K0 = 4'sd1, K1 = 4'sd2 } k_t;
  // L — single-bit bases with NO range
  typedef enum bit { L0, L1 } l_t;
  typedef enum logic { M0, M1 } m_t;
  // N — value that does NOT fit in 32 bits, on a 64-bit base
  typedef enum longint unsigned { N0 = 64'd5000000000, N1 = 64'd6000000000 } n_t;
  // O — reg base
  typedef enum reg [3:0] { O0, O1 } o_t;
  // P — a typedef OF a typedef'd enum (reference goes through two typedefs)
  typedef a_t ap_t;
endpackage

module v7_empty;
  logic [63:0] q;
  logic        r;

  // Context held at the WITNESS's: right operand of `==` in an always_comb.
  always_comb begin
    r = 1'b0;
    if      (q == p7::A0) r = 1'b1;   // a0  int unsigned, ZERO
    else if (q == p7::A1) r = 1'b1;   // a1  int unsigned, NONZERO
    else if (q == p7::B0) r = 1'b1;   // b0  byte unsigned
    else if (q == p7::B1) r = 1'b1;   // b1
    else if (q == p7::C0) r = 1'b1;   // c0  shortint unsigned
    else if (q == p7::C1) r = 1'b1;   // c1
    else if (q == p7::D0) r = 1'b1;   // d0  longint
    else if (q == p7::D1) r = 1'b1;   // d1
    else if (q == p7::E0) r = 1'b1;   // e0  longint unsigned
    else if (q == p7::E1) r = 1'b1;   // e1
    else if (q == p7::F0) r = 1'b1;   // f0  integer
    else if (q == p7::F1) r = 1'b1;   // f1
    else if (q == p7::G0) r = 1'b1;   // g0  NEGATIVE
    else if (q == p7::G1) r = 1'b1;   // g1
    else if (q == p7::H0) r = 1'b1;   // h0  unsized-decimal CONTROL (expect 9)
    else if (q == p7::H1) r = 1'b1;   // h1  implicit AFTER an unsized decimal
    else if (q == p7::I0) r = 1'b1;   // i0  expression member
    else if (q == p7::I1) r = 1'b1;   // i1
    else if (q == p7::J0) r = 1'b1;   // j0  '0
    else if (q == p7::J1) r = 1'b1;   // j1  '1
    else if (q == p7::K0) r = 1'b1;   // k0  signed based
    else if (q == p7::K1) r = 1'b1;   // k1
    else if (q == p7::L0) r = 1'b1;   // l0  bit, no range
    else if (q == p7::L1) r = 1'b1;   // l1
    else if (q == p7::M0) r = 1'b1;   // m0  logic, no range
    else if (q == p7::M1) r = 1'b1;   // m1
    else if (q == p7::N0) r = 1'b1;   // n0  > 32 bits
    else if (q == p7::N1) r = 1'b1;   // n1
    else if (q == p7::O0) r = 1'b1;   // o0  reg base
    else if (q == p7::O1) r = 1'b1;   // o1
  end
endmodule
