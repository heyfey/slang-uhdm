// verifier arm 5 — CROSS-PACKAGE refs by BARE imported name (not qualified),
// including an enum member, plus a qualified parameter (not an enum member).
package v5a;
  typedef enum int { E_RED = 3, E_BLU = 4 } e_t;
  parameter A_LIT = 9;
endpackage
package v5b;
  import v5a::*;
  parameter B_BAREENUM = E_RED;
  parameter B_BAREPARM = A_LIT;
  parameter B_QUALPARM = v5a::A_LIT;
  parameter B_QUALENUM = v5a::E_BLU;
endpackage
module v5mod;
  import v5b::*;
endmodule
