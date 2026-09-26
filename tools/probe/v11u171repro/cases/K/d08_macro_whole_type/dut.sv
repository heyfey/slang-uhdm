// § defNetEndOutputCol171
`define LT logic [15:0]
`define DIM [4]
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
`LT q `DIM;
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
