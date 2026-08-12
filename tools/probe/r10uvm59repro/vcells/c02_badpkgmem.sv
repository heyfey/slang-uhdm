// VERIFIER CELL c02 — a `::`-scoped name whose ROOT IS A PACKAGE and whose
// member DOES NOT EXIST: a DIFFERENT Invalid species from an unbound type
// parameter, same four-conjunct gate.
package p59c02;
  function int pf59(int i); return i + 1; endfunction
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      int i = p59c02::nosuchfn(1);
      m_flag = 1;
    endfunction
    function void x2();
      int i = p59c02::nosuchparam;
      m_flag = 1;
    endfunction
    function void x3();          // in-cell CONTROL: bound package function
      int i = p59c02::pf59(2);
      m_flag = 1;
    endfunction
  endclass
endpackage
