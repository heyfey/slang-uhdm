// § unitOobBodyArgRefUnbound432
function automatic int uf(int a); return a; endfunction
class C;
extern static function int f(int a);
endclass
function int C::f(int a);
return uf(a) + $clog2(a);
endfunction
