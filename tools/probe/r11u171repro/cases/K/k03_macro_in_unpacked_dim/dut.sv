// § defNetEndOutputCol171
`define NN 4
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
logic [15:0]  q  [`NN];
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
