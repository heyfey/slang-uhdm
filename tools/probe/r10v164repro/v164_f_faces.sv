// r10v164 ARM F -- EVERY CAST FACE INSIDE THE CONDITION COLUMN, and the
// statement shapes the condition column does NOT own.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// The brief's face list, in ONE in-body class method so that the HOME is held
// fixed and only the FACE varies:  type / size / enum / typedef / signed /
// unsigned casts; a cast of a cast; a cast inside a binary, a ternary, a
// concat (R0b's family -- MEASURED, never legislated); $cast the system call;
// the cast in an assert / assume / cover / if / case / case item / while /
// do-while / for condition; in an assignment, an argument, a return.
//
// The `while` / `do-while` / `for` / `repeat` / `forever` conditions and the
// `case ... inside` item are MUST-STAY cells: the patch's window is the three
// if / if_else / case CONDITION sites and nothing else, so any movement there
// is over-reach.

package smithy164;
  typedef enum bit [2:0] {AWL, BODKIN, FROE, ADZE} tool_e;
  typedef bit [7:0] octet_t;
  typedef int unsigned reckon_t;
  parameter int GIRTH = 6;
  int unsigned hoard = 5;
endpackage

import smithy164::*;

class Faces164;
  int    trove   = 3;
  tool_e implement = BODKIN;
  int    roster [4];

  function automatic int every_face(int unsigned burden, bit [7:0] parcel,
                                    tool_e kit);
    int       barrow = 41;
    octet_t   sliver = 8'hA5;
    reckon_t  gauge  = 9;
    logic [3:0] flitch = 4'b1010;
    int       verdict = 0;

    // ==== CAST KINDS, all in an `if` CONDITION ============================
    if (int'(barrow) == 41)             verdict = 1;   // f01 TYPE cast, local
    if (8'(barrow) == 8'd41)            verdict = 2;   // f02 SIZE cast (literal)
    if (GIRTH'(barrow) == 41)           verdict = 3;   // f03 SIZE cast (param)
    if (tool_e'(barrow) == BODKIN)      verdict = 4;   // f04 ENUM cast
    if (octet_t'(barrow) == 8'd41)      verdict = 5;   // f05 TYPEDEF cast
    if (signed'(sliver) == -91)         verdict = 6;   // f06 SIGNED cast
    if (unsigned'(barrow) == 41)        verdict = 7;   // f07 UNSIGNED cast
    if (reckon_t'(burden) == 9)         verdict = 8;   // f08 TYPEDEF cast, FORMAL

    // ==== NESTED CASTS ====================================================
    if (octet_t'(int'(barrow)) == 8'd41) verdict = 9;  // f09 cast OF a cast
    if (int'(octet_t'(sliver)) == 165)   verdict = 10; // f10 the other order
    if (int'(signed'(sliver)) == -91)    verdict = 11; // f11 type of sign cast

    // ==== A CAST INSIDE A LARGER EXPRESSION ===============================
    if ((int'(barrow) + 1) == 42)        verdict = 12; // f12 inside a BINARY
    if (int'(barrow) == 41 && barrow == 41) verdict = 13; // f13 cast + BARE twin
    if ((burden != 0 ? int'(barrow) : 0) == 41) verdict = 14; // f14 in a TERNARY arm
    if (int'(burden != 0 ? barrow : 0) == 41)   verdict = 15; // f15 ternary UNDER cast
    if ({4'd0, int'(flitch)} != 0)       verdict = 16; // f16 in a CONCAT (R0b family)
    if (int'({flitch, flitch}) != 0)     verdict = 17; // f17 CONCAT under a cast

    // ==== A CAST OF SOMETHING THAT IS NOT A SIMPLE NAME ===================
    if (int'(roster[1]) == 0)            verdict = 18; // f18 ARRAY ELEMENT under cast
    if (int'(parcel[3:0]) == 0)          verdict = 19; // f19 PART SELECT under cast
    if (int'(smithy164::hoard) == 5)     verdict = 20; // f20 PACKAGE var under cast
    if (int'(trove) == 3)                verdict = 21; // f21 CLASS PROPERTY under cast
    if (int'(this.trove) == 3)           verdict = 22; // f22 this. PROPERTY under cast
    if (int'(kit) == 1)                  verdict = 23; // f23 ENUM-TYPED FORMAL

    // ==== A CAST INSIDE A CALL ARGUMENT INSIDE A CONDITION ================
    if ($sformatf("%0d", int'(barrow)) != "")  verdict = 24; // f24 cast in ARG in COND
    if (helper164(int'(barrow)) == 41)         verdict = 25; // f25 cast in USER-CALL ARG in COND

    // ==== $signed / $unsigned AS SYSTEM CALLS (not the paCast arm) ========
    if ($signed(sliver) == -91)          verdict = 26; // f26 $signed  SYSCALL
    if ($unsigned(barrow) == 41)         verdict = 27; // f27 $unsigned SYSCALL

    // ==== $cast THE SYSTEM CALL ===========================================
    if ($cast(implement, barrow))        verdict = 28; // f28 $cast in an IF cond
    void'($cast(implement, barrow));                   // f29 $cast as a statement

    // ==== CASE CONDITION / CASE ITEM ======================================
    case (int'(barrow))
      41:      verdict = 30;                           // f30 cast in CASE COND
      default: verdict = 31;
    endcase
    case (barrow)
      int'(gauge): verdict = 32;                       // f31 cast in a CASE ITEM
      default:     verdict = 33;
    endcase
    casex (int'(flitch))
      4'b1x1x: verdict = 34;                           // f32 cast in a CASEX cond
      default: verdict = 35;
    endcase
    casez (int'(flitch))
      4'b1?1?: verdict = 36;                           // f33 cast in a CASEZ cond
      default: verdict = 37;
    endcase
    case (barrow) inside
      [int'(gauge):50]: verdict = 38;                  // f34 cast in CASE-INSIDE item
      default:          verdict = 39;
    endcase
    unique if (int'(barrow) == 41)       verdict = 40; // f35 UNIQUE if
    priority if (int'(barrow) == 41)     verdict = 41; // f36 PRIORITY if
    if (int'(barrow) == 41)              verdict = 42; // f37 if / ELSE IF chain
    else if (int'(gauge) == 9)           verdict = 43; // f38 the ELSE-IF condition
    else                                 verdict = 44;

    // ==== ASSERT / ASSUME / COVER (the r10uvm161 column, must not change) ==
    assert (int'(barrow) == 41);                       // f40 ASSERT cond
    assume (int'(gauge) == 9);                         // f41 ASSUME cond
    cover  (int'(barrow) == 41);                       // f42 COVER cond

    // ==== LOOP CONTROLS (NOT the condition column -- must stay) ===========
    while (int'(barrow) > 41)   barrow = barrow - 1;   // f50 WHILE cond
    do   barrow = barrow + 1;
    while (int'(barrow) < 41);                         // f51 DO-WHILE cond
    for (int spar = 0; int'(spar) < 2; spar = spar + 1) // f52 FOR cond
      verdict = verdict + 1;
    repeat (int'(gauge)) verdict = verdict + 1;        // f53 REPEAT count
    foreach (roster[ix])
      if (int'(ix) == 0) verdict = verdict + 1;        // f54 cast in a FOREACH-body if

    // ==== ASSIGNMENT / ARGUMENT / RETURN (not the condition column) =======
    gauge   = reckon_t'(barrow);                       // f60 ASSIGN rhs
    verdict = verdict + helper164(int'(gauge));        // f61 ARG
    if (verdict == 0)
      return int'(barrow);                             // f62 RETURN
    return verdict;
  endfunction

  function automatic int helper164(int unsigned dowel);
    return int'(dowel);                                // f70 RETURN cast, formal
  endfunction
endclass

module harness164_f;
  Faces164 fc;
  int outcome;
  initial begin
    fc = new();
    outcome = fc.every_face(9, 8'hA5, BODKIN);
  end
endmodule
