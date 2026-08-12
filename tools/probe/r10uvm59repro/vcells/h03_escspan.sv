// VERIFIER CELL h03 - ESCAPED-QUALIFIER SPAN LAW: vary the final identifier's
// length to separate "start of final id" from "one past its end".
package p59h03;
  class gen59 #(type \Tesc = int);
    static bit m_flag;
    function void x1();
      int i = \Tesc ::g();
      m_flag = 1;
    endfunction
    function void x2();
      int i = \Tesc ::getlongername();
      m_flag = 1;
    endfunction
  endclass
endpackage
