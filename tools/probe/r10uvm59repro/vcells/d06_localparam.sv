// VERIFIER CELL d06 - an unbound scoped ref in a CONSTANT expression.
package p59d06;
  class gen59 #(type T = int);
    localparam int L59 = T::WIDTH;
    static bit m_flag;
    function void x1();
      int i = L59;
      m_flag = 1;
    endfunction
  endclass
endpackage
