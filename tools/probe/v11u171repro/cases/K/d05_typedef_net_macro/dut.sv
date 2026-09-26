// § defNetEndOutputCol171
`define WIDTH 16
typedef logic [`WIDTH-1:0] word_t;
module dut (input logic clk, input word_t d, output word_t o);
word_t q_data [4];
logic [`WIDTH-1:0] [1:0] p2 [2];
always_ff @(posedge clk) q_data[0] <= d;
assign o = q_data[0] ^ p2[0][0];
endmodule
