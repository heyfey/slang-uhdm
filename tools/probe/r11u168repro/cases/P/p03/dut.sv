// § paramBaseSelTsInstName168
module sub #(parameter [7:0] P = 8'h5a, parameter I = 3) (output [1:0] o);
wire [1:0] w = P[I +: 2];
assign o = w;
endmodule
module top(output [1:0] o); sub s(.o(o)); endmodule
