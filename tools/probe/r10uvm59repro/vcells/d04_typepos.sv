// VERIFIER CELL d04 - a scoped name in TYPE position through a type parameter.
package p59d04;
  class gen59 #(type T = int);
    static bit m_flag;
    T::mytype_t v1;
    function void x1();
      m_flag = 1;
    endfunction
  endclass
endpackage
