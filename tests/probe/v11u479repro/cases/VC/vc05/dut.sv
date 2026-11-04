// § parenCallCallee479
class C; static function int sf(); return 5; endfunction endclass
module top(output int z); initial z = (C::sf()); endmodule
