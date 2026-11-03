// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction endclass
module top(output int z); initial z = (C::sf(1)) + (C::sf(2)); endmodule
