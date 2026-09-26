// § paramBaseSelTsInstName168 § memLeftFormalArgLoc169
module sub #(parameter I = 1) (input [7:0] v, output [3:0] o);
function automatic int f(int x); return x + 1; endfunction
localparam J = f(I);
wire [3:0] w = v[J+3:J];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
