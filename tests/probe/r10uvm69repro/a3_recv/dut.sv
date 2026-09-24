// r10uvm69repro/a3_recv.sv — THE OVER-FIRE GUARD: every receiver kind that is
// NOT the enclosing function's return variable, in the STATEMENT position where
// the collapse is active, plus the two axes the neighbouring passes own.
//
// The law this pass lands fires on ONE receiver kind.  This arm is the negative
// control for all the others: an ordinary body local, a formal argument, a class
// property, a `this.`-rooted property, a receiver naming a DIFFERENT function,
// and a CHAINED receiver whose FIRST segment is the return name.
//
// BOUNDARY, measured not assumed: the parens-less forms belong to
// § parensLessCallIsPathRefObj / § parensLessFuncRefIsRefObj (r10svs2).  Cells
// P1/P2 exist so this pass can PROVE it left them alone, not to change them.
package p3;

  class cH;
    int v;
    function void touch(int x); v = x; endfunction
    function int  peek();       return v; endfunction
  endclass

  class cW;
    cH inner;
    function new(); inner = new(); endfunction
  endclass

  function int other_fn(int x); return x; endfunction

  // N1 — ORDINARY BODY LOCAL receiver, statement.  MUST stay a method shape.
  function int n_local(int n);
    cH loc;
    loc = new();
    loc.touch(n);                 // N1
    n_local = n;
  endfunction

  // N2 — FORMAL ARGUMENT receiver, statement.  MUST stay a method shape.
  function int n_formal(cH arg, int n);
    arg.touch(n);                 // N2
    n_formal = n;
  endfunction

  // N3 — a receiver naming a DIFFERENT function (not the enclosing one).
  //      The collapse must NOT reach it: `other_fn` is not this function's
  //      return variable.
  function int n_otherfn(int n);
    cH other_fn_h;
    other_fn_h = new();
    other_fn_h.touch(n);          // N3
    n_otherfn = n;
  endfunction

  class c3;
    cH prop;
    cW wrap;
    function new(); prop = new(); wrap = new(); endfunction

    // N4 — CLASS PROPERTY receiver, statement.
    function int n_prop(int n);
      prop.touch(n);              // N4
      n_prop = n;
    endfunction

    // N5 — `this.`-rooted property receiver, statement (§ thisRecvCall11).
    function int n_this(int n);
      this.prop.touch(n);         // N5
      n_this = n;
    endfunction

    // N6 — CHAINED receiver whose FIRST segment is the return name
    //      (§ deepRecvCall11's territory).  The collapse keys on a receiver
    //      that is EXACTLY the return name; a dotted path that merely STARTS
    //      with it must keep whatever shape deepRecvCall11 already builds.
    function cW n_chain(int n);
      n_chain = new();
      n_chain.inner.touch(n);     // N6
    endfunction

    // N7 — the return name as an ARGUMENT of a method call on something else.
    function cH n_asarg(int n);
      cH loc2;
      loc2 = new();
      n_asarg = new();
      loc2.touch(n_asarg.peek()); // N7
    endfunction
  endclass

  // P1 — PARENS-LESS method call on the return name, statement position.
  //      r10svs2 owns this cell; recorded, not targeted.
  function string p_noparens(int n);
    int k;
    p_noparens = "abcd";
    k = p_noparens.len;           // P1  (expression, parens-less)
  endfunction

  // P2 — parens-less call on an ordinary local, the matching control.
  function int p_noparens_loc(int n);
    string s;
    s = "abcd";
    p_noparens_loc = s.len;       // P2
  endfunction

  // Q1 — the collapse cell itself, repeated here so this arm carries a POSITIVE
  //      control and a reader can see the law fire beside the cells it must not
  //      reach.
  function cH q_positive(int n);
    q_positive = new();
    q_positive.touch(n);          // Q1
  endfunction

endpackage

module a3_top;
  import p3::*;
  int r;
  initial begin
    r = other_fn(1);
  end
endmodule
