// § castInvalidOperandSyntax292
package p;
  class gen #(type T = int);
    int y;
    function void x1();
      y = int'(T::get());
    endfunction
    function void x2();
      y = 32'(T::get());
    endfunction
    function void x3();
      y = signed'(T::get());
    endfunction
    function void x4();
      y = int'(T::get()) + 1;
    endfunction
  endclass
endpackage
