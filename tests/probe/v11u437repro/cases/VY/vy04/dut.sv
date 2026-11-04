// § newLhsHpSelFirstSpan437
class C; int v; endclass
class H; C c[2]; endclass
module top;
H h;
int idx[2];
initial begin h = new; h.c[idx[1]] = new; end
endmodule
