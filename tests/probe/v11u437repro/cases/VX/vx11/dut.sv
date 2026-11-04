// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial begin cs[0] = new; cs[1] = cs[0]; end
endmodule
