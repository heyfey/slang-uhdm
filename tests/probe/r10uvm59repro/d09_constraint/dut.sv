// VERIFIER CELL d09 - an unbound scoped ref inside a CONSTRAINT.
package p59d09;
  class gen59 #(type T = int);
    rand int x;
    static bit m_flag;
    constraint c59 { x < T::MAX; }
    function void x1();
      m_flag = 1;
    endfunction
  endclass
endpackage
