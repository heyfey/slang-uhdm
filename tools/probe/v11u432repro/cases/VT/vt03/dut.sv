// § tpProtoRetDefaultTs432
class C #(type T = logic signed [7:0], type U = int);
extern static function U f();
extern static function T g();
endclass
function C::U C::f();
return 1;
endfunction
function C::T C::g();
return 2;
endfunction
