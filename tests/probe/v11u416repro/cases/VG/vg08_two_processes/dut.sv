// § genCaseItemProcNoFull416
module top #(parameter W = 3) (input logic clk, input logic [3:0] d, output logic [3:0] q, r);
  case (W)
    1: begin : g end
    default: begin
      always_ff @(posedge clk) q <= d;
      always_comb begin : cb r = ~d; end
    end
  endcase
endmodule
