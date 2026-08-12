// r10svs3 ARM a4 — the two things a3 left open.
//
// (1) THE CONSTRUCTOR WITH A *LIST* BODY.  a3's p2 measured a constructor whose
// WHOLE body is the drop (golden keeps an EMPTY assignment there), which is a
// SINGULAR vpiStmt slot.  A constructor with several statements is a statement
// LIST, and Surelog compiles constructor bodies through
// `compileClassConstructorDeclaration` — a routine that shares no code with
// compileFunction (§ constructorBodyElementShift27).  Whether the LIST rule
// holds there decides whether this pass's law may touch constructor bodies at
// all, and uvm-1.2 constructors are full of `this.<m> = new(...)`.
//
// (2) THE FUNCTION-SPAN QUESTION.  Golden ends the `function` object's span at
// the QUALIFIER on the SVSwitch head (82:1-82:8 covers `virtual `) while ours
// runs to the body end.  The generated `UHDM::Compare` reads NO span field on
// ANY class, so this is cmp-INVISIBLE and dump-only — but it costs nothing to
// measure the qualifier matrix here and record it as ranked residue.
//   q1  constructor, LIST body: ordinary stmt, drop, ordinary stmt
//   q2  constructor, LIST body: TWO drops and one ordinary stmt
//   q3  `virtual function` holding a drop            (+ span cell)
//   q4  plain `function` holding a drop              (+ span cell)
//   q5  `static function` — no `this` available, so an ORDINARY assignment
//                                                     (+ span cell)
//   q6  `task` holding a drop                        (+ span cell)
//   q7  `extern function` defined OUT OF BODY        (+ span cell)
//   q8  drop nested TWO list levels deep (begin inside begin)
//   q9  `this.h = new(1);` — class `new` WITH an argument list
//   q10 `protected virtual function` — TWO qualifiers before `function`
virtual class spanbase;
  pure virtual function void pv();
endclass

class spans extends spanbase;
  logic [7:0] d[];
  logic [7:0] e[];
  int         s;
  spans       h;
  static int  ss;

  function new(int k);
    s = k;
    this.d = new[3];
    e = new[2];
  endfunction

  function void q2();
    s = 1;
    this.d = new[3];
    this.e = new[4];
    s = 2;
  endfunction

  virtual function void q3();
    this.d = new[3];
    s = 3;
  endfunction

  function void q4();
    this.d = new[3];
    s = 4;
  endfunction

  static function void q5();
    ss = 5;
    ss = 6;
  endfunction

  task q6();
    this.d = new[3];
    s = 6;
  endtask

  extern function void q7();

  function void q8();
    s = 8;
    begin
      this.d = new[3];
      s = 9;
    end
  endfunction

  function void q9();
    this.h = new(1);
    s = 9;
  endfunction

  protected virtual function void q10();
    this.d = new[3];
    s = 10;
  endfunction

  virtual function void pv();
    s = 11;
  endfunction
endclass

function void spans::q7();
  this.d = new[3];
  s = 7;
endfunction

module top4;
  spans sp;
  initial begin
    sp = new(1);
    sp.q2();
    sp.q3();
    sp.q4();
    spans::q5();
    sp.q6();
    sp.q7();
    sp.q8();
    sp.q9();
  end
endmodule
