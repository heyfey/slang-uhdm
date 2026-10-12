// § castInvalidOperandSyntax292
package p;
  typedef logic [3:0] n_t;
  class gen #(type T = int, type U = int);
    int y;
    logic [3:0] z;
    function void x1(); z = n_t'(T::get()); endfunction
    function void x2(); y = int'(U::make(1)); endfunction
    function void x3(); y = int'((T::get())); endfunction
  endclass
endpackage
