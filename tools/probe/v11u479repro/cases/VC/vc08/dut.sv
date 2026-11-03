// § parenCallCallee479
class C; static function int sf(int a); return a; endfunction endclass
module top(output int z); if (1) begin : g initial z = (C::sf(1)); end endmodule
