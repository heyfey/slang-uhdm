// r10uvm28 t38b — the `super.new` ARGUMENT axis of the binding law decoded in
// t38a.  t38a shows a constructor's `super.new(a, s)` binds its io_decl
// arguments in golden and not in ours, with every other position already
// equal.  The open question is whether `super.new` is special or simply an
// ordinary CALL whose arguments follow § classArgBind12, so each cell below
// feeds `super.new` a different class of operand, and an ordinary
// `super.<method>()` and an object-qualified call are included as controls.
package pk;

  class base;
    int b;
    function new(int x = 0, string s = "");
      b = x;
    endfunction
    function void bm(int y);
    endfunction
  endclass

  // super.new fed a BARE LOCAL and an INITIALISED LOCAL
  class s_local extends base;
    int p;
    function new(int a);
      int lb;
      int li = 2;
      super.new(lb, "z");
      p = li;
    endfunction
  endclass

  // super.new fed a CLASS PROPERTY (of this class) and a formal
  class s_prop extends base;
    int p;
    function new(int a);
      super.new(p, "z");
      p = a;
    endfunction
  endclass

  // super.new fed an OPERATION over a formal, and a nested call
  class s_expr extends base;
    int p;
    function new(int a);
      super.new(a + 1, "z");
      p = a;
    endfunction
  endclass

  // super.<ordinary method> called from a constructor, and from a method
  class s_othermeth extends base;
    int p;
    function new(int a);
      super.new(a, "z");
      super.bm(a);
      p = a;
    endfunction
    function void go(int a);
      super.bm(a);
      p = a;
    endfunction
  endclass

  // an object-qualified call in a constructor and in a method
  class s_objcall extends base;
    int p;
    base o;
    function new(int a);
      super.new(a, "z");
      o = new(a, "z");
      o.bm(a);
      p = a;
    endfunction
    function void go(int a);
      o.bm(a);
      p = a;
    endfunction
  endclass

  // a constructor with NO port list whose super.new names a local
  class s_noport extends base;
    int p;
    function new();
      int lb;
      super.new(lb, "z");
      p = lb;
    endfunction
  endclass

  // an OUT-OF-BODY constructor: same super.new formal-argument shape
  class s_oob extends base;
    int p;
    extern function new(int a);
  endclass

  function s_oob::new(int a);
    super.new(a, "z");
    p = a;
  endfunction

endpackage

module top;
  pk::s_local a1;
  pk::s_prop a2;
  pk::s_expr a3;
  pk::s_othermeth a4;
  pk::s_objcall a5;
  pk::s_noport a6;
  pk::s_oob a7;
  initial begin
    a1 = new(1);
    a2 = new(1);
    a3 = new(1);
    a4 = new(1);
    a5 = new(1);
    a6 = new();
    a7 = new(1);
  end
endmodule
