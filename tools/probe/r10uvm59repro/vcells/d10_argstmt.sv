// VERIFIER CELL d10 - R8: a STATEMENT-position call whose ARGUMENT is unbound,
// next to the same call with a bound argument as the in-cell control.
package p59d10;
  class conc59;
    static function conc59 get(); return null; endfunction
    function void note(conc59 w, string s); endfunction
  endclass
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1(string nm);
      conc59 f = conc59::get();
      f.note(T::get(), nm);
    endfunction
    function void x2(string nm);
      conc59 f = conc59::get();
      f.note(conc59::get(), nm);
    endfunction
  endclass
endpackage
