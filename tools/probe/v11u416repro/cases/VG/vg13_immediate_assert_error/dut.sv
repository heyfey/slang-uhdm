// § genCaseItemProcNoFull416
module top #(parameter W = 3) (input logic clk, input logic a);
  case (W)
    1: begin : g end
    default:
      always @(posedge clk) begin
        assert (a) else $error("bad");
      end
  endcase
endmodule
