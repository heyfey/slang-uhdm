// r10uvm48 arm t67a — the STATIC-SCOPED `::` REFERENCE AT THE BASE OF A
// `.member[.member].call()` CHAIN.  The corpus site (uvm_comparer.svh:156,
// `uvm_object::__m_uvm_status_container.scope.set_arg(name);`) is a STATEMENT,
// and golden collapses the WHOLE statement to one bare ref_obj named
// `uvm_object::__m_uvm_status_container` spanned over the QUALIFIER ALONE.
// Two models fit that one site and they differ everywhere else:
//   STATEMENT rule   — a whole statement whose root is a class-scoped `::`
//                      reference collapses to that reference.
//   EXPRESSION rule  — any such chain collapses to its base wherever it stands.
// C5/C6/C10/C13 are the DECIDERS: the same chain as an R-VALUE inside a larger
// expression, as a whole Rhs, as a call ARGUMENT and on a PACKAGE qualifier.
//
//  C1  STATEMENT, 2 levels, call WITH arguments            (the corpus shape)
//  C2  STATEMENT, call DIRECTLY on the static base, no args
//  C3  STATEMENT, 2 levels, call with NO arguments
//  C4  STATEMENT, 3 levels deep
//  C5  R-VALUE inside a LARGER expression  <-- decides statement vs expression
//  C6  R-VALUE as the whole Rhs
//  C7  PROPERTY read, one level, no call
//  C8  PROPERTY read, two levels, no call
//  C9  LVALUE (assignment target)
//  C10 call ARGUMENT position
//  C11 CONTROL: the pure § staticScopedRef12 shape, no chain at all
//  C12 PACKAGE qualifier, STATEMENT chain with arguments
//  C13 PACKAGE qualifier, R-VALUE in a larger expression
//  C14 PACKAGE qualifier, PROPERTY read
//  C15 the reader is a PACKAGE FUNCTION, not a class method
//  C16 the reader is a MODULE initial block
package p67;

  class leaf67;
    int depth;
    function void set_arg(string s);
      depth = s.len();
    endfunction
    function void touch();
      depth = depth + 1;
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
    function void touch();
      val = val + 1;
    endfunction
  endclass

  class holder67;
    mid67 scope = new();
    int hval;
    function void touch();
      hval = hval + 1;
    endfunction
  endclass

  class base67;
    static holder67 stat = new();
    static int sint = 7;
  endclass

  holder67 pkgh = new();

  class rdr67;
    int y;
    function void c1(string nm);
      base67::stat.scope.set_arg(nm);
    endfunction
    function void c2();
      base67::stat.touch();
    endfunction
    function void c3();
      base67::stat.scope.touch();
    endfunction
    function void c4(string nm);
      base67::stat.scope.sub.set_arg(nm);
    endfunction
    function void c5();
      y = base67::stat.scope.sub.get_depth() + 1;
    endfunction
    function void c6();
      y = base67::stat.scope.sub.get_depth();
    endfunction
    function void c7();
      y = base67::stat.hval;
    endfunction
    function void c8();
      y = base67::stat.scope.val;
    endfunction
    function void c9();
      base67::stat.hval = 3;
    endfunction
    function void c10();
      $display("%0d", base67::stat.scope.sub.get_depth());
    endfunction
    function void c11();
      y = base67::sint;
    endfunction
    function void c12(string nm);
      p67::pkgh.scope.set_arg(nm);
    endfunction
    function void c13();
      y = p67::pkgh.scope.sub.get_depth() + 1;
    endfunction
    function void c14();
      y = p67::pkgh.hval;
    endfunction
  endclass

  function void pf67(string nm);
    base67::stat.scope.set_arg(nm);
  endfunction

endpackage

module t67a;
  import p67::*;
  int m_y;
  initial begin
    rdr67 r;
    r = new();
    base67::stat.scope.set_arg("m");
    m_y = base67::stat.scope.sub.get_depth() + 1;
    r.c1("a");
    r.c2();
    r.c3();
    r.c4("b");
    r.c5();
    r.c6();
    r.c7();
    r.c8();
    r.c9();
    r.c10();
    r.c11();
    r.c12("c");
    r.c13();
    r.c14();
    pf67("d");
    $display("%0d %0d", r.y, m_y);
  end
endmodule
