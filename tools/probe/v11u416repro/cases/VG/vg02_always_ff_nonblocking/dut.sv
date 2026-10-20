// § genCaseItemProcNoFull416
module top #(parameter W = 3) (input logic clk, input logic [3:0] d, output logic [3:0] q);
  case (W)
    1: begin : g end
    default:
      always_ff @(posedge clk) begin
        q <= d;
      end
  endcase
endmodule
