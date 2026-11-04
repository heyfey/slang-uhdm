// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  logic [3:0] x;
  case (W)
    1: begin : g end
    default:
      always @* begin
        for (int j = 0; j < 4; j++) x[j] = 1'b0;
      end
  endcase
endmodule
