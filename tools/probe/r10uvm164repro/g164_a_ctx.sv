// r10uvm164 ARM A -- THE SEVEN CONTEXTS, cast against no-cast.
// S castOperandNeverBindsInCondWindow164.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// One IN-BODY class method, control depth 0 throughout (the depth half of
// S refVarLocalWindowBinds5 is not what this arm measures), each of the seven
// contexts the brief names read TWICE -- once through a cast, once bare -- so
// that an arm cell that agrees with golden is separated from an arm cell that
// TESTS the law.  The names are deliberately unlike each other and unlike the
// arm letters (a grid that calls everything a_t/b_t/c_t confirms itself).
package pk_ctx164;
  typedef enum bit [2:0] {WARM, TEPID, FRIGID} thermal_e;
  typedef int unsigned tally_t;
  int unsigned pkg_gauge = 3;
endpackage

import pk_ctx164::tally_t;

class Contexts164;
  int    depot     = 7;              // a class PROPERTY (must stay bare both sides)
  static int ledger = 9;             // a class STATIC property

  function automatic int seven_ways(int unsigned quota, bit [3:0] nibble);
    int      spool = 5;              // a body LOCAL
    tally_t  ticker = 2;
    string   verdict;

    // ---- 1. IF CONDITION -------------------------------------------------
    if (int'(spool) == 5)            depot = 1;   // a01 cast   LOCAL
    if (spool == 5)                  depot = 2;   // a02 bare   LOCAL   (control)
    if (int'(quota) == 7)            depot = 3;   // a03 cast   FORMAL
    if (quota == 7)                  depot = 4;   // a04 bare   FORMAL  (control)

    // ---- 2. CASE CONDITION ----------------------------------------------
    case (int'(ticker))
      2:       depot = 5;                          // a05 cast   LOCAL
      default: depot = 6;
    endcase
    case (ticker)
      2:       depot = 7;                          // a06 bare   LOCAL   (control)
      default: depot = 8;
    endcase

    // ---- 3. CASE ITEM ----------------------------------------------------
    case (nibble)
      4'(spool):  depot = 9;                       // a07 cast   in an ITEM
      4'b0001:    depot = 10;
      default:    depot = 11;
    endcase
    case (nibble)
      nibble:     depot = 12;                      // a08 bare   ITEM    (control)
      default:    depot = 13;
    endcase

    // ---- 4. ASSERT CONDITION --------------------------------------------
    assert (int'(spool) == 5);                     // a09 cast
    assert (spool == 5);                           // a10 bare           (control)

    // ---- 5. ASSIGNMENT ---------------------------------------------------
    ticker = tally_t'(spool);                      // a11 cast   RHS
    ticker = spool;                                // a12 bare   RHS     (control)

    // ---- 6. CALL ARGUMENT ------------------------------------------------
    verdict = $sformatf("%0d", int'(spool));       // a13 cast   under an ARG
    verdict = $sformatf("%0d", spool);             // a14 bare   ARG     (control)

    // ---- 7. RETURN -------------------------------------------------------
    if (verdict == "")
      return int'(quota);                          // a15 cast   in a RETURN
    return spool;                                  // a16 bare   RETURN  (control)
  endfunction

  // The SAME seven, with a CLASS PROPERTY, a class STATIC and a PACKAGE
  // variable as the referent -- the three the eager binder can never reach, so
  // any movement here would be the term over-reaching.
  function automatic int seven_ways_far(int unsigned quota);
    int shim = 0;
    if (int'(depot) == 7)                 shim = 1;   // a21 cast PROPERTY
    if (depot == 7)                       shim = 2;   // a22 bare PROPERTY
    if (int'(ledger) == 9)                shim = 3;   // a23 cast STATIC prop
    if (ledger == 9)                      shim = 4;   // a24 bare STATIC prop
    if (int'(pk_ctx164::pkg_gauge) == 3)  shim = 5;   // a25 cast PACKAGE var
    if (pk_ctx164::pkg_gauge == 3)        shim = 6;   // a26 bare PACKAGE var
    case (int'(depot))
      7:       shim = 7;                              // a27 cast PROPERTY, case cond
      default: shim = 8;
    endcase
    return shim + int'(quota);                        // a28 cast FORMAL, return
  endfunction
endclass

module harness164_a;
  Contexts164 cx;
  int outcome;
  initial begin
    cx = new();
    outcome = cx.seven_ways(7, 4'd5) + cx.seven_ways_far(1);
  end
endmodule
