// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  logic [3:0] x;
  case (W)
    3: always @* begin int k; k = W; x = k; end
    default: begin : d end
  endcase
endmodule
