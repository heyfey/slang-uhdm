// § dynArrNewElemLvalueBase437
module top;
int d[2][];
int i = 1;
initial begin d[i] = new[4]; d[i-1] = new[i]; end
endmodule
