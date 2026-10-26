// § newLhsSelCgCopyAtIndex437
interface ifc(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial cs[1] = new();
endinterface
module top(input a); ifc u(a); endmodule
