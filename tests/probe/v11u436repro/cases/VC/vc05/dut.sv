// § cgArrDefNetDimEnd436v
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg c4[4];
initial foreach (c4[i]) c4[i] = new();
endmodule
