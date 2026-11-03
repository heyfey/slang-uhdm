// § parenCallCallee479
class C; int v; function int m(int a); return a + v; endfunction endclass
module top(output int z); C h; initial begin h = new; z = (h.m(1)); end endmodule
