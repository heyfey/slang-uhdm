// § unitOobBodyRefChainName432
class C #(int p = 1);
extern static function int f();
endclass
function int C::f();
return p + C::p;
endfunction
