// § castInvalidOperandSyntax292
package p;
  typedef logic [3:0] n_t;
  class gen #(type T = int, type U = int);
    int y;
    logic [3:0] z;
    function void x1();
      y = int'(T::get());
    endfunction
  endclass
endpackage
