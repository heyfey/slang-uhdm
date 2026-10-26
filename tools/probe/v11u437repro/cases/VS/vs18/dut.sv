// § newLhsHpSelFirstSpan437
class C; int v; endclass
class H; C c[2]; endclass
module top;
H h[2];
initial begin h[0] = new; h[0].c[1] = new; end
endmodule
