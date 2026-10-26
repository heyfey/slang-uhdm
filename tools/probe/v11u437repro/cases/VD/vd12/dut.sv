// § dynArrNewElemLvalueBase437
class C; int v; endclass
module top;
C d[2][];
initial d[0] = new[2];
endmodule
