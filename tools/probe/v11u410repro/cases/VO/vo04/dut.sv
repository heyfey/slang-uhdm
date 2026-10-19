// § oobUnitClsTdUnsupported410
typedef int u_t;
class C;
  typedef u_t my_t;
  extern function int f(my_t a);
endclass
function int C::f(my_t a);
  my_t l = a;
  return l;
endfunction
module top; C c = new; endmodule
