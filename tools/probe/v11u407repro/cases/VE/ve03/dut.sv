// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, y = 0, clk = 0;
  if (1) begin : g
    sequence seq;
      @(posedge clk) a ##1 b;
    endsequence
    initial begin
      @seq y = 1;
    end
  end
endmodule
