// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  logic [3:0] x;
  case (W)
    1: begin : g end
    default:
      always @* begin : nb
        int k;
        begin : inner
          int j;
          j = W;
          k = j;
        end
        x = k;
      end
  endcase
endmodule
