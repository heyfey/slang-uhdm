// § paramBaseSelTsInstName168
module sub #(parameter I = 1) (input [7:0] v, output [3:0] o);
localparam J = I + 1;
wire [3:0] w = v[J+3:J];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
