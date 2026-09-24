// r10uvm48 arm t67d — the LVALUE half and the last two positions.
// C9/D7/E5 all show golden renaming the final segment to `@@BAD_SYMBOL@@` and
// spanning the WHOLE lvalue when a `::`-rooted CHAIN is an assignment target.
// This arm asks whether that is a property of the CHAIN or of LVALUE-ness, which
// decides whether § staticScopedRef12's own bare arm has an unmeasured half:
//
//  H1  `base67::sint = 3;`         class STATIC lvalue, NO chain
//  H2  `q67::qi = 3;`              package VARIABLE lvalue, NO chain (control:
//                                  r10apb3 already measured this one)
//  H3  `base67::sbits[1] = 1'b1;`  class STATIC select lvalue
//      (label corrected by the pass-48 verifier: this comment said
//      `base67::sarr[1] = 3;`, which is not what the source below writes)
//  H4  `q67::qh.hval = 3;`         package-variable CHAIN lvalue from OUTSIDE
//  H7  `sink(base67::stat.hval);`  the chain as a USER call's argument, where
//                                  § classArgBind12 opens the binding window
//  H8  the chain inside a FUNCTION IN A MODULE (neither class nor package)
//  H10 `base67::stat.scope.do_it();` a TASK call through the chain (a different
//                                  emitter arm from the function call)
package q67;
  class qhold67;
    int hval;
  endclass
  qhold67 qh = new();
  int qi = 3;
endpackage

package p67;

  class leaf67;
    int depth;
    task do_it();
      depth = depth + 1;
    endtask
    function void set_arg(string s);
      depth = s.len();
    endfunction
  endclass

  class holder67;
    leaf67 scope = new();
    int hval;
  endclass

  class base67;
    static holder67 stat = new();
    static int sint = 7;
    static logic [7:0] sbits;
  endclass

  class rdr67;
    int y;
    function void sink(int v);
      y = v;
    endfunction
    function void h1();
      base67::sint = 3;
    endfunction
    function void h2();
      q67::qi = 3;
    endfunction
    function void h3();
      base67::sbits[1] = 1'b1;
    endfunction
    function void h4();
      q67::qh.hval = 3;
    endfunction
    function void h7();
      sink(base67::stat.hval);
    endfunction
    task h10();
      base67::stat.scope.do_it();
    endtask
  endclass

endpackage

module t67d;
  import p67::*;
  int m_y;
  function int h8(int k);
    base67::stat.scope.set_arg("h8");
    return k + base67::stat.hval;
  endfunction
  initial begin
    rdr67 r;
    r = new();
    r.h1();
    r.h3();
    r.h2();
    r.h4();
    r.h7();
    r.h10();
    m_y = h8(1);
    $display("%0d %0d", r.y, m_y);
  end
endmodule
