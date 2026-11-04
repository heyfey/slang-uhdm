// § tpProtoRetDefaultTs432
typedef struct packed { logic [3:0] a; logic b; } s_t;
class C #(type T = s_t);
extern static function T f();
endclass
function C::T C::f();
return '0;
endfunction
