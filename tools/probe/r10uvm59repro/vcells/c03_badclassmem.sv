// VERIFIER CELL c03 — a CONCRETE class qualifier with a member that DOES NOT
// EXIST (bad member access, Invalid species #3).
package p59c03;
  class conc59;
    static int sint;
    static function int get(); return 1; endfunction
  endclass
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      int i = conc59::nosuch();
      m_flag = 1;
    endfunction
    function void x2();
      int i = conc59::nosuchprop;
      m_flag = 1;
    endfunction
  endclass
endpackage
