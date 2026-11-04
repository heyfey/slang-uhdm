// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, clk = 0;
  initial begin
    @seq y = 1;
  end
  sequence seq;
    @(posedge clk) a ##1 b;
  endsequence
endmodule
