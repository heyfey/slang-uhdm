// § hiddenBlockVarMintNoFile207 (a hidden variable read in an event control, a condition, and a system call argument)
module m (clk, in, out);
input clk, in;
output out;
reg out;
always @(posedge clk) begin : blk
logic [1:0] w;
w = {in, in};
if (w[0]) out = w[1];
$display("%b", w);
end
endmodule
