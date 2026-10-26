// § dynArrNewElemLvalueBase437
module top;
int d[2][];
int idx[2];
initial d[idx[0]] = new[idx[1] + 1];
endmodule
