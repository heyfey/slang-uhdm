// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C a[string];
C q[$];
initial begin a["k"] = new; q.push_back(null); q[0] = new; end
endmodule
