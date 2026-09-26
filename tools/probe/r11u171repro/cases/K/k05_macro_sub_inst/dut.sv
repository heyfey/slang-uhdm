// § defNetEndOutputCol171
`define DW 32
module sub #(parameter N = 2) (input logic clk, input logic [15:0] d, output logic [15:0] o);
logic [`DW/2-1:0]     q  [N];
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
sub #(.N(3)) u (clk, d, o);
endmodule
