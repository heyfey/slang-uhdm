// § dynArrNewElemLvalueBase437
module top;
int d[2][];
always @* d[0] = new[3];
final d[1] = new[1];
endmodule
