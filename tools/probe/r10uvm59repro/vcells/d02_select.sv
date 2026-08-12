// VERIFIER CELL d02 - SELECT on an unbound scoped ref (read and index position).
package p59d02;
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
  endclass
endpackage
