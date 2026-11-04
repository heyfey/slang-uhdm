// § classRetFillUnsized433
class C #(type T = logic [3:0]);
  extern function T g();
endclass
function C::T C::g();
  return '0;
endfunction
module top; endmodule
