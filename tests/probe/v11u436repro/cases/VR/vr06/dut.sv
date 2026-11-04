// § genClsNoDefRangeSyntax436
virtual class C #(parameter int N);
localparam int W = N + 1;
static function logic [W-1:0] f();
f = '0;
endfunction
endclass
