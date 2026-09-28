// § defPortPackedTsKeepsWholeSpan200
module sub #(parameter N = 2) (input var [N-1:0] [3:0] a, input bit [N-1:0][3:0] b, output reg [N-1:0][3:0] d);
  always_comb d = a ^ b;
endmodule
module p05 (input [2:0][3:0] a, input [2:0][3:0] b, output [2:0][3:0] d);
  sub #(3) u (.a(a), .b(b), .d(d));
endmodule
