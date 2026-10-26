// § newLhsVarSelNameSpan437
class C; int v; endclass
module top;
C c[2][3];
initial for (int i = 0; i < 2; i++) for (int j = 0; j < 3; j++) c[i][j] = new;
endmodule
