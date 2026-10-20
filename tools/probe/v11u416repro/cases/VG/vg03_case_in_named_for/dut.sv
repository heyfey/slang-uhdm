// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  logic [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : gl
    case (W)
      1: begin : g end
      default:
        always @* begin int k; k = i; x[i] = k[0]; end
    endcase
  end
endmodule
