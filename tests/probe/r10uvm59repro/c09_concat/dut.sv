// VERIFIER CELL c09 — the R5 shape: a CONCATENATION with an unbindable scoped
// operand.  Must be IDENTICAL on both binaries (pre-existing residue) — a change
// here would be a NEW reshape, not an add.
package p59c09;
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      string s = {"a", T::type_name, "b"};
      m_flag = 1;
    endfunction
    function void x2();
      string s = {"a", T::get_name(), "b"};
      m_flag = 1;
    endfunction
  endclass
endpackage
