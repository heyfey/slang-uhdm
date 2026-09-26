// § defNetEndOutputCol171
`define WIDTH 16
module dut (input logic [15:0] d, output logic [15:0] o);
wire [`WIDTH-1:0] [1:0] w2;
wire [`WIDTH-1:0] wa [2];
assign w2[0] = d;
assign o = w2[0] ^ wa[0];
endmodule
