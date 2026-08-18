// vbuvm13 arm a3 — THE IN-CLASS LISTING must bind NOTHING in a default value,
// whatever expression shape stands between the ref and the top.  Every cell here
// is an IN-BODY class method (or an extern PROTOTYPE listing, or a pure virtual)
// whose default value names an EARLIER FORMAL from inside a window that
// ExprEmit's bind gate treats specially: a USER call's argument list
// (classArgBindDepth12), a method call's argument list, a `this.`-rooted call, a
// receiver-qualified call, a SYSTEM call's compound argument, a concatenation
// INSIDE a call argument, and a call nested two deep.
package pa3;
  int gv3 = 1;
  function int r3(int x); return x; endfunction
  function int r3b(int x, int y); return x+y; endfunction

  class ch3;
    int prop3;
    function int helper(int x);                             return x; endfunction
    // ---- the WINDOW shapes, all IN-BODY -----------------------------
    function int w_call  (int a, int b = r3(a));            return a+b; endfunction
    function int w_call2 (int a, int b = r3b(a, a));        return a+b; endfunction
    function int w_deep  (int a, int b = r3(r3(a)));        return a+b; endfunction
    function int w_catarg(int a, int b = r3({a, a}));       return a+b; endfunction
    function int w_opnarg(int a, int b = r3(a + 1));        return a+b; endfunction
    function int w_syscmp(int a, int b = $bits(a + 1));     return a+b; endfunction
    function int w_meth  (int a, int b = helper(a));        return a+b; endfunction
    function int w_this  (int a, int b = this.helper(a));   return a+b; endfunction
    function int w_castc (int a, int b = int'(r3(a)));      return a+b; endfunction
    function int w_ternc (int a, int b = (a>0) ? r3(a) : 0); return a+b; endfunction
    // ---- the same shapes as an extern PROTOTYPE + OUT-OF-BODY def ----
    extern function int x_call(int a, int b = r3(a));
    extern function int x_meth(int a, int b = helper(a));
  endclass
  function int ch3::x_call(int a, int b = r3(a));           return a+b; endfunction
  function int ch3::x_meth(int a, int b = helper(a));       return a+b; endfunction

  virtual class vc3;
    pure virtual function int pv_call(int a, int b = r3(a));
  endclass

  // ---- the same shapes in a PACKAGE FREE FUNCTION: all must BIND ----
  function int p_call  (int a, int b = r3(a));              return a+b; endfunction
  function int p_catarg(int a, int b = r3({a, a}));         return a+b; endfunction
  function int p_deep  (int a, int b = r3(r3(a)));          return a+b; endfunction
endpackage

module m_a3;
  import pa3::*;
  ch3 h;
  int z;
  initial begin
    h = new();
    z = h.w_call(1);  z = h.w_call2(1); z = h.w_deep(1);   z = h.w_catarg(1);
    z = h.w_opnarg(1); z = h.w_syscmp(1); z = h.w_meth(1); z = h.w_this(1);
    z = h.w_castc(1); z = h.w_ternc(1);  z = h.x_call(1);  z = h.x_meth(1);
    z = p_call(1);    z = p_catarg(1);   z = p_deep(1);
  end
endmodule
