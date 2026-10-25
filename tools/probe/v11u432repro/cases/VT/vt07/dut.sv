// § tpProtoRetDefaultTs432
class C #(type T = int);
extern static function T f();
extern static function T g();
endclass
function C::T C::f();
return 1;
endfunction
function C::T C::g();
return 2;
endfunction
