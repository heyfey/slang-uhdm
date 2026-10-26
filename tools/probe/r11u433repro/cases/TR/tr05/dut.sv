// § classRetFillUnsized433
class C;
  typedef logic [5:0] w_t;
  extern function w_t g();
endclass
function C::w_t C::g();
  return '1;
endfunction
module top; endmodule
