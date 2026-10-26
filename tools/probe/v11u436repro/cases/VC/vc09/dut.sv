// § cgArrayElemUnsupportedTs436
interface ifc(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg c3[3];
endinterface
module top(input clk, input a);
ifc u(clk, a);
endmodule
