// § unitOobBodyArgRefUnbound432
class C;
extern static function int f(int n);
extern static function int h(int n);
static function int k(int n); return n; endfunction
endclass
function int C::f(int n);
if (n == 0) return 0;
return f(n - 1) + h(n) + k(n);
endfunction
function int C::h(int n);
return n;
endfunction
