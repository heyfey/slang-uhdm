// § cgArrDefNetDimEnd436v
module top(input clk, input [3:0] a);
covergroup cg(int lim) @(posedge clk); coverpoint a { bins lo = {[0:lim]}; } endgroup
cg c2[2];
initial begin c2[0] = new(3); c2[1] = new(7); end
endmodule
