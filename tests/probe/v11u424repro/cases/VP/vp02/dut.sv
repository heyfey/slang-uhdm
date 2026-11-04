// § tpRetOobRefVar424
package pk;
class C #(type T = logic [3:0]);
  extern virtual function T g();
endclass
function C::T C::g();
  return '0;
endfunction
endpackage
module top; endmodule
