// § castInvalidOperandSyntax292
package p;
  class gen #(type T = int);
    static bit m_flag;
    function void x1();
      int i = int'(T::get());
      m_flag = 1;
    endfunction
  endclass
endpackage
