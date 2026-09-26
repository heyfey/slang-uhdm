// § paramBaseSelTsInstName168
module sub #(parameter I = 1, parameter J = I + 2) (input [7:0] v, output [3:0] o);
wire [3:0] w = v[J+1:J-2];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub #(.I(2)) s(.v(v), .o(o)); endmodule
