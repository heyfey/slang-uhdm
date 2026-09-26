// § defNetEndOutputCol171
`define DEPTH(x) (x \
   * 2)
module dut (input logic clk, input logic [7:0] d, output logic [7:0] o);
logic [7:0] q_data [`DEPTH(2)];
always_ff @(posedge clk) q_data[0] <= d;
assign o = q_data[0];
endmodule
