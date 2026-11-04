// § defPortPackedTsKeepsWholeSpan200
interface ifc (input [1:0][3:0] a, input logic [1:0][3:0] b);
endinterface
program prg (input [1:0][3:0] a, input logic [1:0][3:0] b);
endprogram
module p11 (input [1:0][3:0] a);
  ifc i (.a(a), .b(a));
  prg p (.a(a), .b(a));
endmodule
