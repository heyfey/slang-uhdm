// § newLhsSelCgCopyAtIndex437
interface ifc(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial foreach (cs[i]) cs[i] = new();
endinterface
