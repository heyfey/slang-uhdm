// § genClsNoDefRangeSyntax436
virtual class C #(parameter int N);
static function logic [N-1:0] f(output logic [N-1:0] o);
o = '0;
return '0;
endfunction
endclass
module top;
endmodule
