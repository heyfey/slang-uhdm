// r10svs3 ARM a3 — THE STATEMENT-POSITION MATRIX for the drop a1/a2 found.
//
// a2 turned up an asymmetry that decides the whole shape of the law, so it gets
// its own arm.  Golden does NOT do one thing with `this.<m> = new...`:
//   * in a statement LIST (a `begin`'s Stmts) it emits NO list element
//   * as the SOLE body of a plain function/task it emits NO vpiStmt at all
//   * as the SOLE branch of an `if`, and as the SOLE body of `function new`, it
//     emits an ASSIGNMENT WITH NEITHER vpiLhs NOR vpiRhs — an EMPTY assignment
// A law that "drops the statement" everywhere would therefore be WRONG in the
// third row, so the boundary has to be measured, not assumed.  Cells:
//   p1  sole body, plain void function            (a2 n4 repeat, no base class)
//   p2  sole body, `function new` in a BASE-LESS class (is it the constructor?)
//   p3  sole body, NON-VOID return function
//   p4  sole body wrapped in an EXPLICIT begin/end
//   p5  sole body of a `while`
//   p6  sole body of a `foreach`
//   p7  sole item of a `case` arm
//   p8  inside `fork`/`join` in a task
//   p9  TWO drops in a list, nothing else
//   p10 a list: ordinary statement, drop, ordinary statement
//   p11 a LIST INSIDE an `if` (begin/end inside the branch)
//   p12 CONTROL: the same list with the `new` replaced by an ordinary RHS
class solo;
  logic [7:0] d[];
  logic [7:0] e[];
  int         s;

  function void p1();
    this.d = new[3];
  endfunction

  function new();
    this.d = new[3];
  endfunction

  function int p3();
    this.d = new[3];
  endfunction

  function void p4();
    begin
      this.d = new[3];
    end
  endfunction

  function void p5();
    while (s) this.d = new[3];
  endfunction

  function void p6();
    foreach (e[i]) this.d = new[3];
  endfunction

  function void p7();
    case (s)
      1: this.d = new[3];
    endcase
  endfunction

  task p8();
    fork
      this.d = new[3];
    join
  endtask

  function void p9();
    this.d = new[3];
    this.e = new[3];
  endfunction

  function void p10();
    s = 1;
    this.d = new[3];
    s = 2;
  endfunction

  function void p11();
    if (s) begin
      this.d = new[3];
      s = 4;
    end
  endfunction

  function void p12();
    s = 1;
    this.d = e;
    s = 2;
  endfunction
endclass

module top3;
  solo ss;
  int r;
  initial begin
    ss = new();
    ss.p1();
    r = ss.p3();
    ss.p4();
    ss.p5();
    ss.p6();
    ss.p7();
    ss.p8();
    ss.p9();
    ss.p10();
    ss.p11();
    ss.p12();
  end
endmodule
