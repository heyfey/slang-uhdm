// § unitOobBodyArgRefUnbound432
class C #(int p = 1, type T = int);
extern static function T f();
endclass
function C::T C::f();
int x;
x = p;
return x;
endfunction
