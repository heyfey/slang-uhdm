// § cgArrayElemUnsupportedTs436
interface ifc(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg c3[3], c5[5];
endinterface
