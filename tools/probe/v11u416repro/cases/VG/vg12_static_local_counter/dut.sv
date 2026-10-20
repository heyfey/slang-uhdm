// § genCaseItemProcNoFull416
module top #(parameter W = 3) (input logic clk);
  case (W)
    1: begin : g end
    default:
      always @(posedge clk) begin : nb
        static int cnt = 0;
        cnt++;
      end
  endcase
endmodule
