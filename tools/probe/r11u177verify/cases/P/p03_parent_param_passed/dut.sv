// § paramBaseSelTsInstName168
module sub #(parameter I = 1) (input [7:0] v, output [3:0] o);
wire [3:0] w = v[I+3:I];
assign o = w;
endmodule
module top #(parameter K = 4) (input [7:0] v, output [3:0] o); sub #(.I(K)) s(.v(v), .o(o)); endmodule
