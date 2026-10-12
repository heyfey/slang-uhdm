// § castInvalidOperandSyntax292
package p;
  class gen #(type T = int);
    function int x1();
      return int'(T::get());
    endfunction
  endclass
endpackage
