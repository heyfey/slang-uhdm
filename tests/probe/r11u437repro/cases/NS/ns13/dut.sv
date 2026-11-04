// § newLhsVarSelNameSpan437
class C; int v; function new(int a = 0); v = a; endfunction endclass
module top;
C c[2][3];
initial begin c[1][2] = new(5); foreach (c[i,j]) c[i][j] = new; end
endmodule
