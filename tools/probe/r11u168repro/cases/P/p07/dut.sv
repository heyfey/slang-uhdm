// § paramBaseSelTsInstName168
module sub #(parameter I = 3) (input [7:0] v, output [3:0] o);
wire [3:0] w = v[I:0];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
