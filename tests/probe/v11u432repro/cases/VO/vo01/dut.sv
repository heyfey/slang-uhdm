// § unitOobBodyArgRefUnbound432
class C;
extern static function int f(int n);
endclass
function int C::f(int n);
int s = 0;
for (int i = 0; i < n; i++) s += i;
return s;
endfunction
