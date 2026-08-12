// VERIFIER CELL c06 — SELECTS: on an unbound scoped ref, and an unbound scoped
// ref used as an INDEX (the § staticScopedLvalueBad48 I4 position).
package p59c06;
  class gen59 #(type T = int);
    static bit m_flag;
    static bit larr[4];
    function void x1();
      bit b = T::sarr[1];
      m_flag = 1;
    endfunction
    function void x2();
      larr[T::sint] = 1'b1;
      m_flag = 1;
    endfunction
    function void x3();
      bit b = T::get()[2];
      m_flag = 1;
    endfunction
  endclass
endpackage
