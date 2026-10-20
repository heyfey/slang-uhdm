// § genCaseItemProcNoFull416
module top #(parameter W = 3) (input logic [3:0] d, output logic [3:0] q, r);
  case (W)
    1: begin : g end
    default: begin
      assign q = d;
      always @* r = d + 1;
    end
  endcase
endmodule
