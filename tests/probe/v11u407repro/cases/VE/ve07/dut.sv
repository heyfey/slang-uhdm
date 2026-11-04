// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, clk = 0;
  sequence s1;
    @(posedge clk) a ##1 b;
  endsequence
  sequence s2;
    @(posedge clk) b ##1 a;
  endsequence
  always @s1 y <= 1;
  always @(s2) y <= 0;
  initial wait (s1.triggered) y = 1;
endmodule
