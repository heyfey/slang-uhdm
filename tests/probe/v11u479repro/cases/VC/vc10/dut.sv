// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction endclass
class D; function int g(); return (C::sf(3)) * 2; endfunction endclass
module top; endmodule
