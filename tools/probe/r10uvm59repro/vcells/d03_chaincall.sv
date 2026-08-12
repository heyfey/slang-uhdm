// VERIFIER CELL d03 - a chain hung off an UNBOUND scoped call (R3 family).
package p59d03;
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      int i = T::get().inst(2);
      m_flag = 1;
    endfunction
    function void x2();
      int i = T::stat.inst(2);
      m_flag = 1;
    endfunction
  endclass
endpackage
