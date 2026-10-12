// § elabConnPsBoundRefChain290
package pk;
parameter int W = 64;
endpackage
module sub(input logic [3:0] a, output logic o);
assign o = ^a;
endmodule
module top(input logic [31:0] x, output logic o);
sub u(.a(x[$clog2(pk::W)-1:2]), .o(o));
endmodule
