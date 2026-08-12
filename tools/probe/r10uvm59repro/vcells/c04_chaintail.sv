// VERIFIER CELL c04 — a `::`-rooted chain whose TAIL is bad, and a `.member`
// chain hung off an unbound scoped call.
package p59c04;
  class conc59;
    static function conc59 get(); return null; endfunction
    function int inst(int i); return i; endfunction
  endclass
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      int i = T::get().nosuchmethod();
      m_flag = 1;
    endfunction
    function void x2();
      int i = conc59::get().nosuchmethod();
      m_flag = 1;
    endfunction
    function void x3();
      int i = T::get().a.b;
      m_flag = 1;
    endfunction
  endclass
endpackage
