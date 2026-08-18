// vbuvm13 arm a1 — DEFAULT-VALUE EXPRESSION FORMS.  One question per cell: does
// a ref inside a formal's default value carry vpiActual?  Axes: the SHAPE of the
// expression around the ref (bare / ternary / cast / concat / replication /
// index / part-select / call arg / system call / inside / assignment pattern /
// nested twice), crossed with PACKAGE FREE FUNCTION (must BIND) and IN-BODY
// CLASS METHOD (must stay BARE).  Also: a SELF-reference (slang accepts
// `int a = a`) and the earlier formal read TWICE in one expression.
package pa1;
  typedef enum int {A1_A = 1, A1_B = 2} e1_t;
  int pv1 = 3;
  function int r1(int x); return x; endfunction

  // ---- package free function: every shape ------------------------------
  function int f_bare (int a, int b = a);                     return a+b; endfunction
  function int f_tern (int a, int b = (a > 1) ? a : 2);       return a+b; endfunction
  function int f_cast (int a, int b = int'(a));               return a+b; endfunction
  function int f_ecast(int a, int b = int'(e1_t'(a)));        return a+b; endfunction
  function int f_cat  (int a, int b = {a, a});                return a+b; endfunction
  function int f_repl  (int a, int b = {2{a[0]}});            return a+b; endfunction
  function int f_idx  (int a, bit [7:0] b = 8'(a));           return a; endfunction
  function int f_bsel (int a, int b = a[0]);                  return a+b; endfunction
  function int f_psel (int a, int b = a[3:0]);                return a+b; endfunction
  function int f_call (int a, int b = r1(a));                 return a+b; endfunction
  function int f_sys  (int a, int b = $bits(a));              return a+b; endfunction
  function int f_ins  (int a, int b = (a inside {1,2}));      return a+b; endfunction
  function int f_twice(int a, int b = a + a);                 return a+b; endfunction
  function int f_two  (int a, int c, int b = a + c);          return a+b+c; endfunction
  function int f_deep (int a, int b = (((a))) + (a * 2));     return a+b; endfunction
  function int f_mixv (int a, int b = a + pv1);               return a+b; endfunction
  // SELF-reference: slang resolves `a` to the formal itself.
  function int f_self (int a = a);                            return a; endfunction

  // ---- in-body class method: the SAME shapes, all must stay BARE -------
  class ca1;
    function int m_bare (int a, int b = a);                   return a+b; endfunction
    function int m_tern (int a, int b = (a > 1) ? a : 2);     return a+b; endfunction
    function int m_cast (int a, int b = int'(a));             return a+b; endfunction
    function int m_cat  (int a, int b = {a, a});              return a+b; endfunction
    function int m_call (int a, int b = r1(a));               return a+b; endfunction
    function int m_sys  (int a, int b = $bits(a));            return a+b; endfunction
    function int m_ins  (int a, int b = (a inside {1,2}));    return a+b; endfunction
    function int m_two  (int a, int c, int b = a + c);        return a+b+c; endfunction
    function int m_self (int a = a);                          return a; endfunction
    function int m_pv   (int a, int b = a + pv1);             return a+b; endfunction
    function new(int a, int b = a);                           return; endfunction
  endclass
endpackage

module m_a1;
  import pa1::*;
  int z;
  initial begin
    z = f_bare(1); z = f_tern(1); z = f_cast(1); z = f_ecast(1); z = f_cat(1);
    z = f_repl(1); z = f_idx(1);  z = f_bsel(1); z = f_psel(1);  z = f_call(1);
    z = f_sys(1);  z = f_ins(1);  z = f_twice(1); z = f_two(1,2); z = f_deep(1);
    z = f_mixv(1); z = f_self();
  end
endmodule
