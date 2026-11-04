// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction endclass
class D; int k = C::sf(4); endclass
module top; D d; endmodule
