// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  case (W)
    1: begin : g end
    default:
      always @* begin : nb $display("bad"); end
  endcase
endmodule
