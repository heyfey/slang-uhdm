// § seqEventCtrlRefDecl407
module seq_tb ();
  localparam int K = 1;
  logic a = 0, b = 0, y = 0, z = 0, clk = 0;
  sequence seq;
    @(posedge clk) a ##1 b;
  endsequence
  generate
    case (K)
      1: begin : c1
        initial @seq y = 1;
      end
      default: begin : cd
        initial @seq z = 1;
      end
    endcase
  endgenerate
  initial @(seq) z = 0;
endmodule
