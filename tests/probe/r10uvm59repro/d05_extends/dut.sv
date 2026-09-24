// VERIFIER CELL d05 - a scoped name in an EXTENDS clause through a type param.
package p59d05;
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      m_flag = 1;
    endfunction
  endclass
  class inner59 #(type T = int) extends gen59#(T);
    function void y1();
      m_flag = 1;
    endfunction
  endclass
endpackage
