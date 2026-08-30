// r10uvm164 ARM B -- THE HOME MATRIX, and the MODULE-FUNCTION CONTROL.
// S castOperandNeverBindsInCondWindow164.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// The SAME cell -- `if (int'(<local or formal>) == k)` and its `case` twin --
// carried into every home the window can meet.  The MODULE FUNCTION is the
// control r10v161's verifier convicted its own first cut on: Surelog compiles a
// cast's operand with `pexpr == nullptr`, but the very next branch is
// `else if (instance) bindVariable(component, instance, ?)`
// (CompileExpression.cpp:2833-2842), and a module function HAS an instance --
// so golden BINDS there and the term must never fire.  Every non-class home is
// a MUST-STAY.
package pk_home164;
  int unsigned quorum = 4;

  function automatic int pkg_free_fn(int unsigned tide);
    int marsh = 6;
    if (int'(marsh) == 6) return 1;                 // b01 PACKAGE free fn, cast
    if (marsh == 6)       return 2;                 // b02 PACKAGE free fn, bare
    if (int'(tide) == 4)  return 3;                 // b03 PACKAGE free fn, formal
    return 0;
  endfunction

  class Homes164;
    int register = 3;

    // --- IN-BODY method: the column the window opens ---------------------
    function automatic int in_body(int unsigned tide);
      int brim = 8;
      if (int'(brim) == 8) register = 1;            // b11 IN-BODY, cast LOCAL
      if (brim == 8)       register = 2;            // b12 IN-BODY, bare LOCAL
      if (int'(tide) == 4) register = 3;            // b13 IN-BODY, cast FORMAL
      if (tide == 4)       register = 4;            // b14 IN-BODY, bare FORMAL
      case (int'(brim))
        8:       register = 5;                      // b15 IN-BODY, cast case cond
        default: register = 6;
      endcase
      return register;
    endfunction

    // --- IN-BODY STATIC method (the corpus head's own shape) -------------
    static function automatic int in_body_static(int unsigned tide);
      int crest = 2;
      if (int'(crest) == 2) return 11;              // b16 STATIC method, cast LOCAL
      if (int'(tide) == 4)  return 12;              // b17 STATIC method, cast FORMAL
      if (crest == 2)       return 13;              // b18 STATIC method, bare
      return 0;
    endfunction

    // --- IN-BODY task ----------------------------------------------------
    task automatic in_body_task(int unsigned tide);
      int wharf = 1;
      if (int'(wharf) == 1) register = 7;           // b19 TASK, cast LOCAL
      if (wharf == 1)       register = 8;           // b20 TASK, bare LOCAL
      if (int'(tide) == 4)  register = 9;           // b21 TASK, cast FORMAL
    endtask

    // --- IN-BODY constructor ---------------------------------------------
    function new();
      int keel = 0;
      if (int'(keel) == 0) register = 10;           // b22 CTOR, cast LOCAL
      if (keel == 0)       register = 11;           // b23 CTOR, bare LOCAL
    endfunction

    // --- IN-BODY virtual method ------------------------------------------
    virtual function automatic int in_body_virtual(int unsigned tide);
      int prow = 5;
      if (int'(prow) == 5) return 21;               // b24 VIRTUAL, cast LOCAL
      if (prow == 5)       return 22;               // b25 VIRTUAL, bare LOCAL
      return 0;
    endfunction

    extern function int out_of_body(int unsigned tide);
  endclass

  // --- OUT-OF-BODY method: classMethodNoBind is NEVER set, so the window
  // never lifts anything and the term is inert.  golden's own column here is
  // BARE (the class's late-binding list is never walked), so these cells are a
  // RESIDUE this pass does not own, and they must not move.
  function int Homes164::out_of_body(int unsigned tide);
    int stern = 9;
    if (int'(stern) == 9) return 31;                // b31 OOB, cast LOCAL
    if (stern == 9)       return 32;                // b32 OOB, bare LOCAL
    if (int'(tide) == 4)  return 33;                // b33 OOB, cast FORMAL
    return 0;
  endfunction
endpackage

module harness164_b;
  import pk_home164::*;
  Homes164 hm;
  int tally;
  int unsigned mod_gauge = 4;

  // --- MODULE FUNCTION: THE CONTROL.  golden BINDS. --------------------
  function automatic int mod_fn(int unsigned tide);
    int hatch = 12;
    if (int'(hatch) == 12) return 41;               // b41 MODULE fn, cast LOCAL
    if (hatch == 12)       return 42;               // b42 MODULE fn, bare LOCAL
    if (int'(tide) == 4)   return 43;               // b43 MODULE fn, cast FORMAL
    case (int'(hatch))
      12:      return 44;                           // b44 MODULE fn, cast case cond
      default: return 45;
    endcase
  endfunction

  // --- MODULE TASK -----------------------------------------------------
  task automatic mod_task(int unsigned tide);
    int louver = 3;
    if (int'(louver) == 3) tally = 51;              // b45 MODULE task, cast LOCAL
    if (int'(tide) == 4)   tally = 52;              // b46 MODULE task, cast FORMAL
  endtask

  // --- an INITIAL process ----------------------------------------------
  initial begin
    static int rudder = 6;
    hm = new();
    if (int'(rudder) == 6) tally = 61;              // b51 INITIAL, cast LOCAL
    if (rudder == 6)       tally = 62;              // b52 INITIAL, bare LOCAL
    if (int'(mod_gauge) == 4) tally = 63;           // b53 INITIAL, cast MODULE var
    tally = tally + hm.in_body(4) + Homes164::in_body_static(4)
                  + hm.in_body_virtual(4) + hm.out_of_body(4)
                  + mod_fn(4) + pk_home164::pkg_free_fn(4);
    hm.in_body_task(4);
    mod_task(4);
  end
endmodule
