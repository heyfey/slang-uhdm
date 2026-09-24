// r10uvm48 arm t67b — the MUST-NOT-MOVE controls and the remaining spellings of
// a `::`-rooted expression.  t67a proved the collapse is an EXPRESSION rule for
// a `::` root followed by a `.member` chain; this arm asks which OTHER `::`
// roots golden collapses, because the natural implementation ("the syntax is a
// ScopedName") would swallow all of these too:
//
//  D1  `p67::pf67(nm);`             PACKAGE FUNCTION call, statement   (control)
//  D2  `y = p67::pfi(1) + 1;`       PACKAGE FUNCTION call, r-value     (control)
//  D3  `base67::sfunc();`           STATIC CLASS METHOD call, statement
//  D4  `y = base67::sfunc() + 1;`   STATIC CLASS METHOD call, r-value
//  D5  `p67::base67::stat.scope.set_arg(nm);`  THREE-segment root + chain
//  D6  `y = p67::base67::sint;`     THREE-segment root, no chain       (control)
//  D7  `base67::stat.scope.sub.depth = 4;`  DEEP LVALUE
//  D8  `if (base67::stat.scope.sub.get_depth() > 0)`  chain in a CONDITION
//  D9  `base67::stat.scope.set_arg(base67::stat.scope.sub.get_depth() > 0 ?
//        "a" : "b");`               a chain INSIDE another chain's argument
//  E1  `y = base67::sarr[1];`       class-static ARRAY ELEMENT (a select, not a
//                                   `.member`) — decides whether the law may key
//                                   on "the syntax is a ScopedName" alone
//  E2  `y = p67::PARR[1];`          package PARAMETER array element    (control)
//  E3  `y = p67::pkgarr[1];`        package VARIABLE array element
//      (NOT a control — corrected by the pass-48 verifier. E3 COLLAPSES, with a
//      span/fullname residue; the README body has always treated it that way.)
//  E4  `y = p67::pstruct.a;`        package STRUCT member read — a `.member`
//                                   chain that is NOT a class handle
//  E5  `p67::pstruct.a = 5;`        the same as an LVALUE
package p67;

  typedef struct packed {
    int a;
    int b;
  } st67;

  parameter int PARR[0:3] = '{1, 2, 3, 4};

  class leaf67;
    int depth;
    function void set_arg(string s);
      depth = s.len();
    endfunction
    function int get_depth();
      return depth;
    endfunction
  endclass

  class mid67;
    leaf67 sub = new();
    int val;
    function void set_arg(string s);
      val = s.len();
    endfunction
  endclass

  class holder67;
    mid67 scope = new();
    int hval;
  endclass

  class base67;
    static holder67 stat = new();
    static int sint = 7;
    static int sarr[0:3] = '{1, 2, 3, 4};
    static function int sfunc();
      return sint;
    endfunction
  endclass

  st67 pstruct;
  int pkgarr[0:3];

  function void pf67(string nm);
    pkgarr[0] = nm.len();
  endfunction

  function int pfi(int k);
    return k + 1;
  endfunction

  class rdr67;
    int y;
    function void d1(string nm);
      p67::pf67(nm);
    endfunction
    function void d2();
      y = p67::pfi(1) + 1;
    endfunction
    function void d3();
      base67::sfunc();
    endfunction
    function void d4();
      y = base67::sfunc() + 1;
    endfunction
    function void d5(string nm);
      p67::base67::stat.scope.set_arg(nm);
    endfunction
    function void d6();
      y = p67::base67::sint;
    endfunction
    function void d7();
      base67::stat.scope.sub.depth = 4;
    endfunction
    function void d8();
      if (base67::stat.scope.sub.get_depth() > 0)
        y = 1;
    endfunction
    function void d9();
      base67::stat.scope.set_arg(base67::stat.scope.sub.get_depth() > 0 ? "a" : "b");
    endfunction
    function void e1();
      y = base67::sarr[1];
    endfunction
    function void e2();
      y = p67::PARR[1];
    endfunction
    function void e3();
      y = p67::pkgarr[1];
    endfunction
    function void e4();
      y = p67::pstruct.a;
    endfunction
    function void e5();
      p67::pstruct.a = 5;
    endfunction
  endclass

endpackage

module t67b;
  import p67::*;
  int m_y;
  initial begin
    rdr67 r;
    r = new();
    r.d1("a");
    r.d2();
    r.d3();
    r.d4();
    r.d5("b");
    r.d6();
    r.d7();
    r.d8();
    r.d9();
    r.e1();
    r.e2();
    r.e3();
    r.e4();
    r.e5();
    $display("%0d %0d", r.y, m_y);
  end
endmodule
