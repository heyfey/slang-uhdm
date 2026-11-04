// § opCtxRefArgBare201 § portPackedBareImplicitTruncates202v § defPortPackedTsKeepsWholeSpan200
module sub #(parameter N = 2) (input [N-1:0][3:0] a, input wire [N-1:0][3:0] b, output [N-1:0][3:0] y, output [N-1:0][3:0] z);
  function automatic logic [7:0] f(input logic [7:0] q); return ~q; endfunction
  assign y = f(a) + 8'd1;
  assign z = f(b) - f(a);
endmodule
module x08 (input [1:0][3:0] a, output [1:0][3:0] y, output [1:0][3:0] z);
  sub u (.a(a), .b(a), .y(y), .z(z));
endmodule
