// § defNetEndOutputCol171
`define ADD(a,b) ((a)+(b))
`define W 6
module dut (input logic clk, input logic [7:0] d, output logic [7:0] o);
logic [`ADD(`W,1):0]     q  [`ADD(1,2)];
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
