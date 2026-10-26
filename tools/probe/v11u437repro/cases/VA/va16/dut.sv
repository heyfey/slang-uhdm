// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
cg one;
initial begin one = new; cs[0] = one; end
endmodule
