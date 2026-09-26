// § defNetEndOutputCol171
`define W 16
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
`ifdef NOPE
logic [`W-1:0]  q  [8];
`else
logic [`W-1:0]  q  [4];
`endif
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
