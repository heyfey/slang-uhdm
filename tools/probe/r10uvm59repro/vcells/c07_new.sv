// VERIFIER CELL c07 — INTERACTION WITH § invalidNewCallFromSyntax55: a `new`
// whose syntax is a `::`-scoped name, and an unbound `new` inside the SAME
// generic class.  BOTH laws sit in the same Invalid arm; 55 unwraps first.
package p59c07;
  class conc59;
    function new(int i = 0); endfunction
  endclass
  class gen59 #(type T = int, type Tregistry = int);
    static bit m_flag;
    conc59 o;
    function void x1();
      o = conc59::new(3);
      m_flag = 1;
    endfunction
    function void x2();
      T v;
      v = new();
      m_flag = 1;
    endfunction
    function void x3();
      T v = T::new();
      m_flag = 1;
    endfunction
    function void x4();
      T v = Tregistry::type_id::create("n");
      m_flag = 1;
    endfunction
  endclass
endpackage
