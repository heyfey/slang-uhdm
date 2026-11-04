// § parenCallCallee479
class C; int v; static function C mk(); C c = new; return c; endfunction endclass
module top(output int z); initial z = (C::mk().v); endmodule
