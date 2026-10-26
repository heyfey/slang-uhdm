// § genClsNoDefRangeSyntax436
virtual class C #(parameter int N);
extern static function logic [N-1:0] f();
endclass
function logic [C::N-1:0] C::f();
return '0;
endfunction
