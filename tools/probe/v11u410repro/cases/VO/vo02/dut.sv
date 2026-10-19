// § oobUnitClsTdUnsupported410
class C;
  typedef int arr_t [4];
  typedef string s_t;
  extern function void f(arr_t a, s_t b);
endclass
function void C::f(arr_t a, s_t b);
  s_t loc;
  loc = b;
endfunction
module top; C c = new; endmodule
