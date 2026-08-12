// VERIFIER CELL d07 - a DOT (not ::) reference rooted at a type parameter.
package p59d07;
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      int i = T.nosuch;
      m_flag = 1;
    endfunction
  endclass
endpackage
