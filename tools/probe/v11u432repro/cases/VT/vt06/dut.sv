// § tpProtoRetDefaultTs432
module top;
class C #(type T = int);
extern static function T f();
endclass
function C::T C::f();
return 4;
endfunction
endmodule
