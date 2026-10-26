// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
int idx[2];
initial begin idx[0] = 1; cs[idx[0]] = new; end
endmodule
