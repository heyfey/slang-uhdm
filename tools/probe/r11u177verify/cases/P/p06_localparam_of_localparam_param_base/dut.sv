// § paramBaseSelTsInstName168
module sub #(parameter [7:0] P = 8'h5a, parameter I = 1) (input [7:0] v, output [3:0] o);
localparam J = I * 2;
localparam K = J;
wire [3:0] w = P[K+3:K] & v[K+3:K];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
