// r10v164 ARM G -- DEPTH, NESTING AND THE OTHER SILENCES THE WINDOW MEETS.
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// The window this patch opens is a CONDITION EXPRESSION.  This arm asks what
// happens where that expression is not a plain one: inside a NAMED begin
// (S namedBlkLocalNoBind144v's home), inside a CONSTRUCTOR (S ctorSubLocal-
// NoBind144), inside a control body (S controlBodyNoBind28), inside a fork,
// inside a foreach, in a randomize-with inline constraint, and around a
// method CALL whose own arguments live in the condition (S classInBodyRecv-
// CallArgNoBind52 / S classArgBindDepth12).  Each cast cell is paired with its
// bare twin so an agreeing cell is separated from a testing one.
//
// It also carries the 1 / 2 / 3 INSTANCE face: three instantiations of the
// same module, so an elaborated-view cell exists three times and a term that
// reads a stale scope shows up as a per-instance split.

package tannery164;
  typedef enum bit [1:0] {HIDE, PELT, VELLUM} stock_e;
  typedef int unsigned span_t;
endpackage

class Depths164;
  int vat = 2;
  rand int soak;
  int liquor;

  constraint steep { soak inside {[0:9]}; }

  // ---- a CONSTRUCTOR ------------------------------------------------------
  function new(int unsigned lime);
    int bark = 17;
    if (int'(bark) == 17)      vat = 1;     // g01 cast LOCAL  in a CTOR
    if (bark == 17)            vat = 2;     // g02 bare LOCAL  (control)
    if (int'(lime) == 3)       vat = 3;     // g03 cast FORMAL in a CTOR
    case (int'(bark))
      17:      vat = 4;                     // g04 cast LOCAL  ctor case cond
      default: vat = 5;
    endcase
  endfunction

  // ---- a NAMED begin, a control body, a fork, a foreach -------------------
  function automatic int deep(int unsigned tan, int roll [3]);
    int scud = 23;
    int tally = 0;

    begin : currying                        // a NAMED block
      int fleshing = 29;                    // S 144v's shape
      if (int'(fleshing) == 29) tally = 1;  // g11 cast NAMED-BLOCK local
      if (fleshing == 29)       tally = 2;  // g12 bare NAMED-BLOCK local (S144v)
      if (int'(scud) == 23)     tally = 3;  // g13 cast SUBROUTINE local, in named blk
      if (int'(tan) == 5)       tally = 4;  // g14 cast FORMAL, in named blk
    end

    begin                                   // an UNNAMED block
      int scouring = 31;
      if (int'(scouring) == 31) tally = 5;  // g15 cast UNNAMED-block local
      if (scouring == 31)       tally = 6;  // g16 bare UNNAMED-block local
    end

    if (tan != 0) begin                     // a CONTROL BODY (S 28)
      if (int'(scud) == 23)     tally = 7;  // g21 cast, one control body deep
      if (scud == 23)           tally = 8;  // g22 bare, one control body deep
      if (int'(tan) == 5)       tally = 9;  // g23 cast FORMAL, one body deep
      case (int'(scud))
        23:      tally = 10;                // g24 cast, case cond one body deep
        default: tally = 11;
      endcase
    end

    for (int hank = 0; hank < 2; hank = hank + 1)
      if (int'(hank) == 0)      tally = 12; // g25 cast LOOP VAR in a body if

    foreach (roll[pk])
      if (int'(roll[pk]) == 0)  tally = 13; // g26 cast ARRAY ELEM in a foreach if

    fork
      if (int'(scud) == 23)     tally = 14; // g27 cast inside a FORK
      if (scud == 23)           tally = 15; // g28 bare inside a FORK
    join_none

    // ---- a CALL inside the condition, with its OWN arguments -------------
    if (this.echo164(int'(scud)) == 23) tally = 16;  // g31 cast in a THIS-call ARG in a cond
    if (this.echo164(scud) == 23)       tally = 17;  // g32 bare in a THIS-call ARG in a cond
    if (echo164(int'(tan)) == 5)        tally = 18;  // g33 cast in a plain-call ARG in a cond

    // ---- a randomize-with inline constraint inside a condition ----------
    if (this.randomize() with { soak == int'(scud); }) tally = 19; // g34 cast in a WITH
    if (this.randomize() with { soak == scud; })       tally = 20; // g35 bare in a WITH

    // ---- a ternary CONDITION (not the if column) ------------------------
    liquor = (int'(scud) == 23) ? 1 : 0;   // g41 cast in a TERNARY condition
    liquor = (scud == 23) ? 1 : 0;         // g42 bare in a TERNARY condition

    return tally + liquor;
  endfunction

  function automatic int echo164(int unsigned peg);
    return int'(peg);
  endfunction
endclass

module cell164 (input logic clk);
  Depths164 dp;
  int roll [3];
  int outcome;
  initial begin
    dp = new(3);
    outcome = dp.deep(5, roll);
  end
endmodule

// THREE instances of the same module -- the elaborated view carries the class
// method three times over.
module harness164_g;
  logic clk = 0;
  cell164 first  (.clk(clk));
  cell164 second (.clk(clk));
  cell164 third  (.clk(clk));
endmodule
