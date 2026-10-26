// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[int];
initial cs[5] = new();
endmodule
