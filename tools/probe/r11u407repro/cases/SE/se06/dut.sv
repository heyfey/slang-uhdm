// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, clk = 0;
  sequence seq(x);
    @(posedge clk) x ##1 b;
  endsequence
  initial begin
    @(seq(a)) y = 1;
  end
endmodule
