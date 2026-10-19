// § oobUnitClsTdUnsupported410
class C;
  typedef bit [3:0] nib_t;
  extern function nib_t f(nib_t a);
endclass
function C::nib_t C::f(nib_t a);
  return a;
endfunction
module top; C c = new; endmodule
