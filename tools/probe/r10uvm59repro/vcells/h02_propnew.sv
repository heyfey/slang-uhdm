// VERIFIER CELL h02 - CALL SITE 2 (emitClassPropInit29) x the `new` axis: a
// class PROPERTY whose initializer is a scoped `new` and an unbound `new`.
package p59h02;
  class conc59;
    function new(int i = 0); endfunction
  endclass
  class gen59 #(type T = int);
    static bit m_flag;
    conc59 p1 = conc59::new(3);
    T p2 = T::new();
    conc59 p3 = new();
    T p4 = T::get();
    function void x1();
      m_flag = 1;
    endfunction
  endclass
endpackage
