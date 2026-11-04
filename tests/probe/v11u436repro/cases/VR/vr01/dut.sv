// § genClsNoDefRangeSyntax436
virtual class C #(parameter int N, parameter int M = N * 2);
static function logic [M-1:0] f(input logic [N-1:0] d);
f = '0;
endfunction
endclass
