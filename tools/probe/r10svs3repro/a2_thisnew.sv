// r10svs3 ARM a2 — SEPARATE the two halves arm a1 found were BOTH present at
// the SVSwitch site, and bound the statement-POSITION blast radius.
//
// a1's verdict was that `this.d = new[3];` / `this.h = new();` are DROPPED
// ENTIRELY by Surelog while `d = new[3];`, `h.d = new[3];`, `bytes = new[..];`
// and `this.s = 5;` are all KEPT.  Two properties coincide at every dropped
// cell: the LHS is written with the `this` KEYWORD, and the RHS is a `new`.
// This arm varies one at a time, and then asks the question a drop law lives or
// dies on: WHAT HAPPENS TO THE ENCLOSING STATEMENT when the dropped one is the
// only thing inside it.
//   n1  `this.d = e;`              this-LHS, NON-new RHS, dynamic array member
//   n2  `this.h = g;`              this-LHS, NON-new RHS, class-handle member
//   n3  `this.h.d = new[3];`       this-prefixed DEEPER path, new RHS
//   n4  `this.d = new[3](e);`      the COPY form of new[]
//   n5  `super.d = new[3];`        the OTHER keyword-qualified LHS
//   n6  sole branch of an `if`     -- does the if survive with an empty branch?
//   n7  sole body of a `for`
//   n8  a TASK, not a function
//   n9  inside the CONSTRUCTOR `function new`
//   n10 a `begin`/`end` with the drop BETWEEN two ordinary statements
//   n11 TWO drops in a row, nothing else
//   n12 CONTROL: bare `d = new[3];` next to `this.s = 1;` in one body
//   n13 a VIRTUAL function holding a drop -- also the function-SPAN witness
class base2;
  logic [7:0] d[];
endclass

class holder2 extends base2;
  logic [7:0] e[];
  int         s;
  holder2     h;
  holder2     g;

  function void n1();
    this.d = e;
  endfunction

  function void n2();
    this.h = g;
  endfunction

  function void n3();
    this.h.d = new[3];
  endfunction

  function void n4();
    this.d = new[3](e);
  endfunction

  function void n5();
    super.d = new[3];
  endfunction

  function void n6();
    if (s) this.d = new[3];
  endfunction

  function void n7();
    for (int i = 0; i < 2; i++) this.d = new[3];
  endfunction

  task n8();
    this.d = new[3];
  endtask

  function new();
    this.d = new[3];
  endfunction

  function void n10();
    s = 1;
    this.d = new[3];
    s = 2;
  endfunction

  function void n11();
    this.d = new[3];
    this.d = new[4];
  endfunction

  function void n12();
    d = new[3];
    this.s = 1;
  endfunction

  virtual function void n13();
    this.d = new[3];
    s = 3;
  endfunction
endclass

module top2;
  holder2 hh;
  initial begin
    hh = new();
    hh.n1();
    hh.n2();
    hh.n3();
    hh.n4();
    hh.n5();
    hh.n6();
    hh.n7();
    hh.n8();
    hh.n10();
    hh.n11();
    hh.n12();
    hh.n13();
  end
endmodule
