// § newLhsHpSelFirstSpan437
class C; int v; endclass
class H; C c[2]; endclass
module top;
function void f(H h); h.c[0] = new; endfunction
H hh;
initial begin hh = new; f(hh); end
endmodule
