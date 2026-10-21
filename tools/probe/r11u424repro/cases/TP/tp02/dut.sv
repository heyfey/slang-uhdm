// § tpRetOobRefVar424
class C #(type T = logic [7:0]);
  extern function T get(int i);
  function T own(); return 0; endfunction
endclass
function C::T C::get(int i);
  return T'(i);
endfunction
module top; C #(byte) c; endmodule
