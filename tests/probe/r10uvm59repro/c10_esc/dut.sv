// VERIFIER CELL c10 — ESCAPED IDENTIFIER spellings.  splitScopedName12 reads
// `valueText()`, which STRIPS the backslash; Surelog's name text may not.
package p59c10;
  class \esc59 ;
    static function int get(); return 1; endfunction
  endclass
  class gen59 #(type \Tesc = int, type T = int);
    static bit m_flag;
    function void x1();
      int i = \Tesc ::get();
      m_flag = 1;
    endfunction
    function void x2();
      int i = T::\getesc ();
      m_flag = 1;
    endfunction
    function void x3();          // in-cell CONTROL: bound, escaped qualifier
      int i = \esc59 ::get();
      m_flag = 1;
    endfunction
  endclass
endpackage
