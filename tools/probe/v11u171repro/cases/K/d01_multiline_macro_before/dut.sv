// § defNetEndOutputCol171
`define TWO(a, b) \
  a + \
  b
module dut #(parameter N = 4) (input logic clk, input logic [7:0] d, output logic [7:0] o);
localparam int Q = `TWO(1,
   2);
logic [7:0] q_data [N];
always_ff @(posedge clk) q_data[0] <= d;
assign o = q_data[0];
endmodule
