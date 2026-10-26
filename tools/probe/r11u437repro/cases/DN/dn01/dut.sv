// § dynArrNewElemLvalueBase437
module top;
int d[2][];
initial begin d[0] = new[3]; d[1] = new[2](d[0]); end
endmodule
