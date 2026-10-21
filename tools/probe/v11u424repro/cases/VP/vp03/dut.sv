// § tpRetOobRefVar424
class B; endclass
class C #(type T = B);
  extern static function T mk();
endclass
function C::T C::mk();
  return null;
endfunction
module top; endmodule
