// VERIFIER CELL k02 - is golden's bare-FIRST-SEGMENT increment shape a
// pre-existing gap for the BOUND case too?  All three cells bind.
package p59k02;
  class conc59;
    static int sint;
  endclass
  class user59;
    static bit m_flag;
    function void z1();
      conc59::sint++;
      m_flag = 1;
    endfunction
    function void z2();
      conc59::sint += 1;
      m_flag = 1;
    endfunction
    function void z3();
      conc59::sint = 3;
      m_flag = 1;
    endfunction
  endclass
endpackage
