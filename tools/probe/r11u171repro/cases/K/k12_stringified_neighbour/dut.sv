// § defNetEndOutputCol171
`define STR(x) `"x`"
`define W 16
module dut (input logic clk, input logic [15:0] d, output logic [15:0] o);
string s = `STR(abc);
logic [`W-1:0]  q  [4];
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
