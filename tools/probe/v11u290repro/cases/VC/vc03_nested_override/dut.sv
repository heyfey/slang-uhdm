// § elabConnPsBoundRefChain290
module sub #(parameter S = 64)(input logic [$clog2(S)-1:2] a, output logic o);
assign o = ^a;
endmodule
module mid #(parameter T = 64)(input logic [31:0] x, output logic o);
sub #(.S(T)) u(.a(x[$clog2(T)-1:2]), .o(o));
endmodule
module top(input logic [31:0] x, output logic o);
mid #(.T(256)) m(.x(x), .o(o));
endmodule
