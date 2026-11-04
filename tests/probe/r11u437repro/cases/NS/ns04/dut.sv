// § newLhsVarSelNameSpan437
class C; int v; endclass
module top;
C c[2][3];
initial begin c[0][1] = new; end
endmodule
