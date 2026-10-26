// § newLhsVarSelNameSpan437
class C; int v; endclass
module top;
C c[2][2];
initial begin c[0][0] = new; c[1][0] = new c[0][0]; end
endmodule
