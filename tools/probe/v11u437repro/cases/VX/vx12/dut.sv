// § newLhsVarSelNameSpan437
class C; int v; endclass
module top;
C c[2][2];
int i;
initial begin i = 1; c[i][i-1] = new; c[0][i] = new c[i][i-1]; end
endmodule
