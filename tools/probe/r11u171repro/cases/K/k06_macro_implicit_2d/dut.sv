// § defNetEndOutputCol171
`define WW 8
module dut (input wire [15:0] d, output wire [15:0] o);
wire [`WW-1:0][1:0] t;
assign t = d;
assign o = t;
endmodule
