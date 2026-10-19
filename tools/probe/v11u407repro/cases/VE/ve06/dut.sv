// § seqEventCtrlRefDecl407
interface ifc(input logic clk);
  logic a = 0, b = 0, y = 0;
  sequence seq;
    @(posedge clk) a ##1 b;
  endsequence
  initial begin
    @seq y = 1;
  end
endinterface
module seq_tb ();
  logic clk = 0;
  ifc i(clk);
endmodule
