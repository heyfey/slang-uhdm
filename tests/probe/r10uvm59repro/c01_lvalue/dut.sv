// VERIFIER CELL c01 — an UNBOUND `::` LVALUE through a type parameter.
// § staticScopedLvalueBad48 says golden writes FIRST::@@BAD_SYMBOL@@ spanning
// the WHOLE thing for an lvalue Surelog cannot resolve.  If § …59 fires on the
// assignment TARGET it would mint `T::sprop` instead.
package p59c01;
  class conc59;
    static int sint;
  endclass
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      T::sprop = 3;
      m_flag = 1;
    endfunction
    function void x2();          // in-cell CONTROL: bound lvalue
      conc59::sint = 3;
      m_flag = 1;
    endfunction
  endclass
endpackage
