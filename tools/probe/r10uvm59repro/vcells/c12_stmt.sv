// VERIFIER CELL c12 — POSITION: STATEMENT vs EXPRESSION, the campaign's twice-
// missing clause.  A bare unbound scoped call statement, with and without args,
// and one inside a fork/begin.
package p59c12;
  class gen59 #(type T = int);
    static bit m_flag;
    function void x1();
      T::get();
    endfunction
    function void x2();
      T::run(1, "a");
    endfunction
    task x3();
      begin
        T::get();
        m_flag = 1;
      end
    endtask
    function void x4();
      if (m_flag) T::get();
      else T::other();
    endfunction
  endclass
endpackage
