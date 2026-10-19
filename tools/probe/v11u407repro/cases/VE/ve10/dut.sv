// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, z = 0, clk = 0;
  sequence seq;
    @(posedge clk) a ##1 b;
  endsequence
  if (1) begin : g
    sequence seq;
      @(posedge clk) b ##1 a;
    endsequence
    initial @seq y = 1;
  end
  initial @seq z = 1;
endmodule
