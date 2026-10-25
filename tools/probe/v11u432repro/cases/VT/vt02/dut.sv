// § tpProtoRetDefaultTs432
class D; endclass
class C #(type T = D);
extern function T f();
endclass
function C::T C::f();
return null;
endfunction
