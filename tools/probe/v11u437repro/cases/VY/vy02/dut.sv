// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[2];
int idx[2];
initial begin c[0] = new; c[idx[1]] = new c[0]; end
endmodule
