// § unitOobBodyArgRefUnbound432
class C #(type T = int);
  extern function T f(int a);
endclass
function C::T C::f(int a);
  return a;
endfunction
module top; endmodule
