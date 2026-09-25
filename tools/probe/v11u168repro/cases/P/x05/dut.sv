// § paramBaseSelTsInstName168
module sub #(parameter I = 3, parameter [15:0] Q = 16'h1234) (input [7:0] v, output [3:0] o);
localparam int J = I + 1;
wire [3:0] w = Q[J+3:J];
wire [3:0] x = v[J:J-3];
assign o = w ^ x;
endmodule
module top(input [7:0] v, output [3:0] o); sub s1(.v(v), .o(o)); sub #(.I(2)) s2(.v(v), .o()); endmodule
