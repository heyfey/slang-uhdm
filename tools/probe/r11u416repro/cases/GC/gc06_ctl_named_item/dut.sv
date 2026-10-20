// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  case (W)
    1: begin : g end
    default: begin : d
      initial begin $display("bad"); end
    end
  endcase
endmodule
