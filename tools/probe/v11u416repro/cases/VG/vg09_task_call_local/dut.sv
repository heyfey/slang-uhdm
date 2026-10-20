// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  logic [3:0] x;
  task automatic t(input int v); x = v; endtask
  case (W)
    1: begin : g end
    default:
      initial begin int k; k = 2; t(k); end
  endcase
endmodule
