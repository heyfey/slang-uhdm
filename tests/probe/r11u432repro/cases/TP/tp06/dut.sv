// § tpProtoRetDefaultTs432
typedef logic [7:0] u8_t;
class C #(type T = u8_t);
  extern function T f();
endclass
function C::T C::f(); return 0; endfunction
module top; endmodule
