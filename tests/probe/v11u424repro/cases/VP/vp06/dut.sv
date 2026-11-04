// § tpRetOobRefVar424
class C #(int W = 4, type T = logic [W-1:0]);
  extern function T get();
  extern task put(T v);
endclass
function C::T C::get(); return '0; endfunction
task C::put(C::T v); endtask
module top; C #(8) c; endmodule
