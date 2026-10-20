// § clsTdArgAliasTwin414
class C;
  typedef int i_t;
  extern function void f(i_t a);
endclass
function void C::f(i_t a);
endfunction
module top;
  C c;
endmodule
