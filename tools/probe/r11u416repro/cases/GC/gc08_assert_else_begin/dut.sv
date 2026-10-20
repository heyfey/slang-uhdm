// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  case (W)
    1: begin : g end
    default:
      initial assert (W == 3) else begin $display("bad"); end
  endcase
endmodule
