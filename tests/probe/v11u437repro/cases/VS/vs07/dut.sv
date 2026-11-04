// § newLhsHpSelFirstSpan437
class C; int v; endclass
class E; C c[2]; endclass
class H; E arr[2]; endclass
module top;
H h;
initial begin h = new; h.arr[0] = new; h.arr[0].c[1] = new; end
endmodule
