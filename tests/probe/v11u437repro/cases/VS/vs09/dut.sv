// § newLhsVarSelNameSpan437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2][2];
initial cs[0][1] = new();
endmodule
