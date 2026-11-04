// § newLhsVarSelNameSpan437
class C; int v; function new(int x); v = x; endfunction endclass
module top;
C c[2][2][2];
initial c[0][1][1] = new(3);
endmodule
