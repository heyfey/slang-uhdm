// § tpProtoRetDefaultTs432
class C #(type T = int);
  extern function T f();
endclass
function C::T C::f(); return 0; endfunction
module top; C #(byte) c; endmodule
