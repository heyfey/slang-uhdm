// § newLhsHpSelFirstSpan437
class C; int v; endclass
class D; C c[2]; endclass
class H; D d; function new(); d = new; endfunction endclass
module top;
H h;
initial begin h = new; h.d.c[1] = new; end
endmodule
