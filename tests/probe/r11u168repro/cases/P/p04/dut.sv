// § paramBaseSelTsInstName168
module sub #(parameter [7:0] P = 8'h5a, parameter I = 3) (input [7:0] v, output [3:0] o);
wire [3:0] w = P[I+3:I] ^ v[I+3:I];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
