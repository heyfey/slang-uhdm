// § dynArrNewElemLvalueBase437
`define D d[0]
module top;
int d[2][];
initial `D = new[3];
endmodule
