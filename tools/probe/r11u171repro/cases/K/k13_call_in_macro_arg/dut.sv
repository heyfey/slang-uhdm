// § defNetEndOutputCol171
`define ID(x) x
`define W 16
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
logic [`ID(`W)-1:0]  q  [`ID(4)];
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
