// § elabConnPsBoundRefChain290
parameter int UW = 64;
module sub(input logic [3:0] a, output logic o);
assign o = ^a;
endmodule
module top(input logic [31:0] x, output logic o);
sub u(.a(x[$clog2(UW)-1:2]), .o(o));
endmodule
