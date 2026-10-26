// § newLhsHpSelFirstSpan437
class C; int v; endclass
interface ifc; C c[2]; endinterface
module top;
ifc u();
initial u.c[0] = new;
endmodule
