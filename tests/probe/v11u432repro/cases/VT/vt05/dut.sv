// § tpProtoRetDefaultTs432
class B #(type T = int);
endclass
class C #(type T = shortint) extends B #(T);
extern static function T f();
endclass
function C::T C::f();
return 3;
endfunction
