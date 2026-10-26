// § dynArrNewElemLvalueBase437
class C; static int d[2][]; endclass
module top;
initial C::d[0] = new[2];
endmodule
