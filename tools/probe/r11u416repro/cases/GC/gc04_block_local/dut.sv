// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  logic [3:0] x;
  case (W)
    1: begin : g end
    default:
      always @* begin int k; k = W; x = k; end
  endcase
endmodule
