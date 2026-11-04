// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction endclass
module sub(output int z); initial z = (C::sf(1)); endmodule
module top; int a, b; sub u1(a); sub u2(b); endmodule
