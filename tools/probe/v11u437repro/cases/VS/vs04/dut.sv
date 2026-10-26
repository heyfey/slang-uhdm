// § newLhsHpSelFirstSpan437
class C; int v; endclass
typedef struct { C c[2]; } s_t;
module top;
s_t s;
initial s.c[0] = new;
endmodule
