// § newLhsHpSelFirstSpan437
class C; int v; function new(int a = 0); v = a; endfunction endclass
class H; C c[2]; endclass
module top;
H h;
initial begin h = new; h.c[0] = new(2); foreach (h.c[i]) h.c[i] = new; end
endmodule
