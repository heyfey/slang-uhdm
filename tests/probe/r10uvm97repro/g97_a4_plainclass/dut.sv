// r10uvm97 arm a4 — the SAME self-referential idiom in a PLAIN (non-generic)
// class, package-homed and module-homed, plus a typedef of ANOTHER class and a
// typedef of a SPECIALIZATION.  MEASUREMENT-ONLY golden arm.
//
// A plain class has exactly ONE slang ClassType, so its `this_type` typedef can
// never produce the duplicate group member pass 97 removes: this arm is the
// control that says the dedup fires ONLY where slang minted a second copy.
package s97d;

  class plain97d;
    typedef plain97d this_type97d;      // self-referential, NON-generic
    this_type97d m_self;
    function this_type97d get(); return m_self; endfunction
  endclass

  class gen97d #(type T = int);
    typedef gen97d #(int) spec97d;      // a SPECIALIZATION, not `#(T)`
    typedef plain97d oth97d;            // ANOTHER class
    spec97d m_spec;
    oth97d  m_oth;
  endclass

  class useint97d extends gen97d #(int);
    function void f(spec97d p); m_spec = p; endfunction
  endclass

  class usebyte97d extends gen97d #(byte);
    function void f(spec97d p); m_spec = p; endfunction
  endclass

endpackage

module top97d;
  class mplain97d;
    typedef mplain97d this_type97d;     // module-homed, `work@` key
    this_type97d m_self;
  endclass
  mplain97d mh;
  initial mh = new();
endmodule
