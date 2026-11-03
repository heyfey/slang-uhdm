// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction function int g(); return (sf(2)); endfunction endclass
module top; endmodule
