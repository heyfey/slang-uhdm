// § newLhsHpSelFirstSpan437
class C; int v; endclass
class H; C c[2]; function void mk(); c[0] = new; this.c[1] = new; endfunction endclass
module top;
H h;
initial begin h = new; h.mk(); h.c[1] = new; end
endmodule
