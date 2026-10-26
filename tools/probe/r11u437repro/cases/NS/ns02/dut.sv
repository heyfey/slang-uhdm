// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[4];
initial foreach (c[i]) c[i] = new;
endmodule
