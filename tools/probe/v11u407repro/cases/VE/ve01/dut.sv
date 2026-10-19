// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, clk = 0;
  sequence seq(x = a);
    @(posedge clk) x ##1 b;
  endsequence
  initial begin
    @seq y = 1;
  end
endmodule
