// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  case (W)
    1: begin : g end
    default:
      initial begin $display("bad"); end
  endcase
endmodule
