// § genClsNoDefRangeSyntax436
virtual class C#(parameter DECODE_W, parameter ENCODE_W = $clog2(DECODE_W));
static function logic [ENCODE_W-1:0] enc(input logic [DECODE_W-1:0] d);
enc = '0;
endfunction
endclass
