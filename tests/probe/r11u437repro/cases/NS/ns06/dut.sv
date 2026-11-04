// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[2];
C s;
initial begin s = new; c[0] = new s; end
endmodule
