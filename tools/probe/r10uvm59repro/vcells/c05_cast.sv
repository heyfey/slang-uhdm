// VERIFIER CELL c05 — CASTS over an unbound scoped call, both directions.
package p59c05;
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      int i = int'(T::get());
      m_flag = 1;
    endfunction
    function void x2();
      int i = T'(3);
      m_flag = 1;
    endfunction
    function void x3();
      int i = $bits(T::get());
      m_flag = 1;
    endfunction
  endclass
endpackage
