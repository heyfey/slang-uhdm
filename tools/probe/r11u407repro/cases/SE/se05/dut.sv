// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, clk = 0;
  sequence seq;
    @(posedge clk) a ##1 b;
  endsequence
  initial begin
    fork
      begin
        @seq y = 1;
      end
    join
  end
endmodule
