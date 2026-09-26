// § defNetEndOutputCol171
module dut #(parameter N = 4) (input logic clk, input logic [7:0] d, output logic [7:0] o);
`include "hdr.svh"
logic [`W-1:0] q_data [N];
logic [`W-1:0][1:0] q2;
always_ff @(posedge clk) q_data[0] <= d;
assign o = q_data[0] ^ q2[0];
endmodule
