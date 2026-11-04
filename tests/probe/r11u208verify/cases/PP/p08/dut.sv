// § defPortPackedTsKeepsWholeSpan200 § portPackedBareImplicitTruncates202v
interface ifc #(parameter N = 2) (input [N-1:0][3:0] a, input wire [N-1:0][1:0] b);
  logic [N-1:0][3:0] q;
  assign q = a;
endinterface
program prg #(parameter N = 2) (input [N-1:0][3:0] a, input logic [N-1:0][1:0] b);
  initial $display(a, b);
endprogram
module p08 (input [1:0][3:0] a, output [1:0][3:0] y);
  ifc #(2) i (.a(a), .b(4'b0));
  prg #(2) pg (.a(a), .b(4'b0));
  assign y = i.q;
endmodule
