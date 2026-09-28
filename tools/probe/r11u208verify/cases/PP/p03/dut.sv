// § defPortPackedTsKeepsWholeSpan200 § portPackedBareImplicitTruncates202v
interface ifc (input [1:0][3:0] a, input wire [1:0][1:0] b);
  logic [1:0][3:0] q;
  assign q = a;
endinterface
program prg (input [1:0][3:0] a, input logic [2:0][1:0] b);
  initial $display(a, b);
endprogram
module p03 (input [1:0][3:0] a, input bit unsigned [1:0][3:0] u, output [1:0][3:0] y);
  ifc i (.a(a), .b(a[0][1:0]));
  prg pg (.a(a), .b(6'b0));
  assign y = i.q ^ u;
endmodule
