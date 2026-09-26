// § defNetEndOutputCol171
`define WW 32
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
logic [`WW/2-1:0][1:0]  m;
always_ff @(posedge clk) m[0] <= d;
assign o = m[0];
endmodule
