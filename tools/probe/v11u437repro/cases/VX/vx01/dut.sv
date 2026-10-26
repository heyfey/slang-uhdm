// § newLhsHpSelFirstSpan437
class C; int v; endclass
class H; C c[2]; endclass
module top;
H h;
initial begin h = new; h.c[0] = new; h.c[1] = new h.c[0]; end
endmodule
