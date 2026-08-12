// VERIFIER CELL c08 — Invalid species with NO `::`: an unresolved DOTTED
// hierarchical/member reference.  MUST NOT fire.
package p59c08;
  class conc59;
    int f;
  endclass
  class gen59 #(type T = int);
    static bit m_flag;
    conc59 c;
    function void x1();
      int i = c.nosuchfield;
      m_flag = 1;
    endfunction
    function void x2();
      int i = nosuchthing;
      m_flag = 1;
    endfunction
    function void x3();
      int i = T.nosuch;
      m_flag = 1;
    endfunction
  endclass
endpackage
