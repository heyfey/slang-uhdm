// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, clk = 0;
  sequence s1;
    @(posedge clk) a ##1 b;
  endsequence
  always @s1 y <= ~y;
endmodule
