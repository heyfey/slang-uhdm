// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  event e;
  case (W)
    1: begin : g end
    default:
      initial begin -> e; end
  endcase
endmodule
