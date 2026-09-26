// § defNetEndOutputCol171
`define DIM(a) [a]
module dut (input logic clk, input logic [7:0] d, output logic [7:0] o);
logic [7:0]     q  `DIM(
   4);
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
