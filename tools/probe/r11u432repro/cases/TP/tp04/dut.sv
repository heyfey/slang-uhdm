// § tpProtoRetDefaultTs432
class C #(type T = int);
  extern static function T f();
  extern static function int h();
endclass
function C::T C::f(); return 1; endfunction
function int C::h(); return 2; endfunction
module top; initial $display(C#()::f()); endmodule
