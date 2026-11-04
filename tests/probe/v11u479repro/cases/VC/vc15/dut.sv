// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction endclass
module top(output int z); initial if ((C::sf(1)) > 0) z = 1; endmodule
