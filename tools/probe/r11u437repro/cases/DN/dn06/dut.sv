// § dynArrNewElemLvalueBase437
module top;
int q[$][];
int a[string][];
initial begin q.push_back({}); q[0] = new[2]; a["x"] = new[1]; end
endmodule
