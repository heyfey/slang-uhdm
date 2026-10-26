// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial if (a) cs[0] = new; else cs[1] = new;
endmodule
