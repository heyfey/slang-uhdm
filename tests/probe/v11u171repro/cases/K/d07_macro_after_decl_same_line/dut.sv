// § defNetEndOutputCol171
`define WIDTH 16
`define N 3
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
logic [`WIDTH-1:0] a [`N], b [`N-1:0];
always_ff @(posedge clk) a[0] <= d;
assign o = a[0] ^ b[0];
endmodule
