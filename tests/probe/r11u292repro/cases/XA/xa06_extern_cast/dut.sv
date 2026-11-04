// § castInvalidOperandSyntax292
package p;
  class gen #(type T = int);
    int y;
    extern function void x1();
  endclass
  function void gen::x1();
    int i = int'(T::get());
    y = i;
  endfunction
endpackage
