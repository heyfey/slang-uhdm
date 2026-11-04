// § newLhsVarSelNameSpan437
`define I0 0
class C; int v; endclass
module top;
C c[2][2];
initial c[`I0][1] = new;
endmodule
