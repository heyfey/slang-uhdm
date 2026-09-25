// § paramBaseSelTsInstName168
module sub #(parameter [7:0] P = 8'h5a, parameter H = 5, parameter L = 2) (input [7:0] v, output [3:0] o);
wire [3:0] w = P[H:L];
assign o = w ^ v[H:L];
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
