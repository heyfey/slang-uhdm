// § seqEventCtrlRefDecl407
module seq_tb ();
  logic a = 0, b = 0, clk = 0;
  logic [1:0] y = 0;
  sequence seq;
    @(posedge clk) a ##1 b;
  endsequence
  for (genvar i = 0; i < 2; i++) begin : g
    initial begin : blk
      @seq y[i] = 1;
    end
  end
endmodule
