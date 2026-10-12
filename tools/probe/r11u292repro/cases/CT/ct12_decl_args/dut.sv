// § castInvalidOperandSyntax292
package p;
  typedef logic [3:0] n_t;
  class gen #(type T = int, type U = int);
    int y;
    logic [3:0] z;
    function void x1();
      int i = int'(U::make(1));
      y = 0;
    endfunction
  endclass
endpackage
