// § newLhsVarSelNameSpan437
class C; int v; endclass
module top;
C c[2][2];
int idx[2];
initial c[idx[0]][1] = new;
endmodule
