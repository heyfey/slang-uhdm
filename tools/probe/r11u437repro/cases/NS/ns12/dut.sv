// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[4];
localparam P = 2;
initial begin c[P] = new; c[P-1] = new(); end
endmodule
