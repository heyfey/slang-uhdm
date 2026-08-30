// r10uvm164 ARM C -- THE CAST-KIND x REFERENT MATRIX, in the CONDITION column.
// S castOperandNeverBindsInCondWindow164.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// Every cast spelling the `paCast` arm can take, every referent kind, one to
// three instances per condition, all inside ONE IN-BODY class method at control
// depth 0 -- the column this pass un-scopes.  `$cast(dst, src)` is here as the
// NEGATIVE: it is an ordinary system call, NOT the `paCast` arm, and its
// arguments must keep whatever they had.
package pk_kind164;
  typedef enum bit [1:0] {IDLE, BUSY, HALT} phase_e;
  typedef byte unsigned octet_t;
  typedef logic signed [7:0] sbyte_t;
  int unsigned lagoon = 11;
endpackage

import pk_kind164::*;

class Kinds164;
  int         mantel  = 21;               // class PROPERTY
  static int  obelisk = 31;               // class STATIC property
  phase_e     stance  = IDLE;

  function automatic int every_cast(int signed drift, bit [3:0] crumb,
                                    phase_e stage);
    int          barrow = 41;             // body LOCAL
    static int   cistern = 51;            // METHOD-STATIC local
    bit [7:0]    plinth = 8'h0F;
    octet_t      furrow = 3;
    sbyte_t      trough = -2;
    int          verdict = 0;

    // ---- cast KINDS, each over a body LOCAL ---------------------------
    if (int'(barrow) == 41)                verdict = 1;   // c01 int' TYPE cast
    if (bit'(barrow))                      verdict = 2;   // c02 bit' cast
    if (unsigned'(barrow) == 41)           verdict = 3;   // c03 unsigned' cast
    if (signed'(plinth) == 15)             verdict = 4;   // c04 signed' cast
    if (6'(barrow) == 6'd41)               verdict = 5;   // c05 SIZE cast
    if (phase_e'(crumb) == BUSY)           verdict = 6;   // c06 ENUM cast (formal)
    if (octet_t'(barrow) == 8'd41)         verdict = 7;   // c07 TYPEDEF cast
    if (int'(bit'(barrow)) == 1)           verdict = 8;   // c08 NESTED casts
    if (octet_t'(int'(barrow)) == 8'd41)   verdict = 9;   // c09 a CAST OF A CAST
    if (int'(barrow) + 1 == 42)            verdict = 10;  // c10 cast in a BINARY
    if ((int'(barrow) == 41) && (barrow == 41)) verdict = 11; // c11 cast AND bare, one cond

    // ---- 1, 2 and 3 INSTANCES in one condition -------------------------
    if (int'(barrow) == 41)                                  verdict = 12; // c12 ONE
    if (int'(barrow) + int'(drift) == 41)                    verdict = 13; // c13 TWO
    if (int'(barrow) + int'(drift) + int'(furrow) == 44)     verdict = 14; // c14 THREE

    // ---- the same casts over the OTHER referents -----------------------
    if (int'(drift) == 0)                  verdict = 15;  // c15 FORMAL
    if (int'(stage) == 0)                  verdict = 16;  // c16 FORMAL, enum-typed
    if (int'(mantel) == 21)                verdict = 17;  // c17 class PROPERTY
    if (int'(obelisk) == 31)               verdict = 18;  // c18 class STATIC prop
    if (int'(cistern) == 51)               verdict = 19;  // c19 METHOD-STATIC local
    if (int'(pk_kind164::lagoon) == 11)    verdict = 20;  // c20 PACKAGE variable
    if (int'(stance) == 0)                 verdict = 21;  // c21 enum-typed PROPERTY

    // ---- the CASE-CONDITION twin of each referent ----------------------
    case (int'(barrow))
      41:      verdict = 22;                              // c22 LOCAL
      default: verdict = 23;
    endcase
    case (int'(drift))
      0:       verdict = 24;                              // c23 FORMAL
      default: verdict = 25;
    endcase
    case (int'(mantel))
      21:      verdict = 26;                              // c24 PROPERTY
      default: verdict = 27;
    endcase
    case (signed'(trough))
      -2:      verdict = 28;                              // c25 signed' in a case cond
      default: verdict = 29;
    endcase

    // ---- THE NEGATIVE: $cast is a CALL, not the paCast arm -------------
    if ($cast(stance, crumb))              verdict = 30;  // c30 $cast as a FUNCTION
    void'($cast(stance, crumb));                          // c31 $cast as a statement
    if ($bits(barrow) == 32)               verdict = 31;  // c32 $bits, a plain syscall
    if ($signed(plinth) == 15)             verdict = 32;  // c33 $signed SYSTEM CALL
    if ($unsigned(drift) == 0)             verdict = 33;  // c34 $unsigned SYSTEM CALL

    return verdict;
  endfunction
endclass

module harness164_c;
  Kinds164 kd;
  int score;
  initial begin
    kd = new();
    score = kd.every_cast(0, 4'd1, IDLE);
  end
endmodule
