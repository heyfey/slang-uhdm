// VERIFIER CELL k01 - LVALUE FLAVOURS of an unbound `::` target: bare assign,
// compound assign, INCREMENT, and an output-argument lvalue (which is NOT an
// assignment's Lhs).  Checks the dead verify agent's X5/X6/X4 sub-shape claims.
package p59k01;
  class gen59 #(type T = int);
    static bit m_flag;
    static int m_i;
    function void sink(output int o); endfunction
    function void y1();
      T::sprop = 3;
      m_flag = 1;
    endfunction
    function void y2();
      T::sprop += 1;
      m_flag = 1;
    endfunction
    function void y3();
      T::sprop++;
      m_flag = 1;
    endfunction
    function void y4();
      sink(T::sprop);
      m_flag = 1;
    endfunction
    function void y5();
      int y = T::sprop;
      m_flag = 1;
    endfunction
  endclass
endpackage
