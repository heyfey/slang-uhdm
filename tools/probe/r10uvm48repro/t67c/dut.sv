// r10uvm48 arm t67c — the gate's remaining halves.  t67a fixed the MODEL
// (EXPRESSION rule, not statement rule); t67b fixed which `::` ROOTS collapse
// (a package FUNCTION call and a static METHOD call do not need touching, a
// package PARAMETER with a select does NOT collapse, a package VARIABLE and a
// class STATIC do).  This arm asks the questions that decide the SYMBOL gate
// and the SPAN, and it carries the two must-not-move controls that the natural
// implementation would break:
//
//  G1  `y = p67::PCFG.a;`      package PARAMETER struct member  <-- the gate
//  G3  `y = base67::LPARR[1];` class LOCALPARAM array element
//  G4  `y = q67::qh.hval;` / `q67::qh.touch();` a pkg-qualified chain from
//      OUTSIDE the declaring package — the r10apb3 shape the existing collapse
//      already handles: does golden span the QUALIFIER or the WHOLE name?
//  G5  `y = q67::qi;`          bare pkg-qualified read from OUTSIDE (span)
//  G6  `y = p67::pkgi;`        bare pkg-qualified read from INSIDE the pkg
//  G7  `assign m_z = q67::qs.a;`    a chain in a CONTINUOUS ASSIGN
//      (label corrected by the pass-48 verifier: this comment said
//      `q67::qh.hval`, which is not what line 111 writes)
//  G8  `cu67::stat.scope.set_arg(nm);` the class lives in the COMPILATION UNIT
//  G9  `stat.scope.set_arg(nm);` the SAME chain written WITHOUT `::` from
//      inside the declaring class — THE must-not-move control
//  G10 `s = p67::E1.name();` / `s = base67::CE1.name();` an ENUM member root
package q67;
  class qmid67;
    int qv;
  endclass
  class qhold67;
    qmid67 scope = new();
    int hval;
    function void touch();
      hval = hval + 1;
    endfunction
  endclass
  typedef struct packed {
    int a;
    int b;
  } qst67;
  qhold67 qh = new();
  qst67 qs;
  int qi = 3;
endpackage

package p67;

  typedef struct packed {
    int a;
    int b;
  } st67;

  typedef enum int {E0 = 0, E1 = 1} e67;

  parameter st67 PCFG = '{a: 1, b: 2};

  int pkgi = 5;

  class leaf67;
    int depth;
    function void set_arg(string s);
      depth = s.len();
    endfunction
  endclass

  class holder67;
    leaf67 scope = new();
    int hval;
  endclass

  class base67;
    localparam int LPARR[0:3] = '{1, 2, 3, 4};
    typedef enum int {CE0 = 0, CE1 = 1} ce67;
    static holder67 stat = new();
    function void g9(string nm);
      stat.scope.set_arg(nm);
    endfunction
  endclass

  class rdr67;
    int y;
    string s;
    function void g1();
      y = p67::PCFG.a;
    endfunction
    function void g3();
      y = base67::LPARR[1];
    endfunction
    function void g4(string nm);
      y = q67::qh.hval;
      q67::qh.touch();
    endfunction
    function void g5();
      y = q67::qi;
    endfunction
    function void g6();
      y = p67::pkgi;
    endfunction
    function void g10();
      s = p67::E1.name();
      s = base67::CE1.name();
    endfunction
  endclass

endpackage

class cu67;
  static p67::holder67 stat = new();
endclass

module t67c;
  import p67::*;
  import q67::*;
  int m_y;
  int m_z;
  assign m_z = q67::qs.a;
  initial begin
    rdr67 r;
    base67 b;
    r = new();
    b = new();
    r.g1();
    r.g3();
    r.g4("a");
    r.g5();
    r.g6();
    r.g10();
    b.g9("b");
    cu67::stat.scope.set_arg("c");
    $display("%0d %0d %0d", r.y, m_y, m_z);
  end
endmodule
