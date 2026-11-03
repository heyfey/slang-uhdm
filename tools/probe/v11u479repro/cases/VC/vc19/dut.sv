// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction endclass
module top(output int z); assign z = (C::sf(1)); endmodule
