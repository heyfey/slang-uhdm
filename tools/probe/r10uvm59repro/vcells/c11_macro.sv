// VERIFIER CELL c11 — the whole scoped reference WRITTEN BY A MACRO.  The span
// is read off token locations; a macro buffer location that is not mapped
// through getFullyOriginalLoc prints a nonsense line/column.
`define SCALL(TT) TT::get()
`define WHOLE int i = T::get();
package p59c11;
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      int i = `SCALL(T);
      m_flag = 1;
    endfunction
    function void x2();
      `WHOLE
      m_flag = 1;
    endfunction
  endclass
endpackage
