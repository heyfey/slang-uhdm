// § paramBaseSelTsInstName168
module sub #(parameter I = 3) (input [7:0] v, output [3:0] o);
wire [3:0] w = {v[I:I-3]};
wire [1:0] x = v[I:2];
assign o = w ^ {2'b0, x};
endmodule
module top(input [7:0] v, output [3:0] o); sub #(.I(4)) s(.v(v), .o(o)); endmodule
