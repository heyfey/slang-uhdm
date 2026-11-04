// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[2];
C q[$];
initial begin c[0] = new; q.push_back(c[0]); q[0] = new c[0]; end
endmodule
