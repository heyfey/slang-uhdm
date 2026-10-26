// § classRetFillUnsized433
class C #(type T = logic [3:0]);
  extern function T g();
  extern function T h();
endclass
function C::T C::g();
  return '1;
endfunction
function C::T C::h();
  T v;
  v = '0;
  return v;
endfunction
module top; endmodule
