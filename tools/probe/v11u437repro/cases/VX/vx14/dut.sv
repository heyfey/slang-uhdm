// § dynArrNewElemLvalueBase437
module top;
int d[2][];
int k;
initial begin k = 1; d[k] = new[k + 2]; end
endmodule
