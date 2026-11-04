// § genNdaSelRhsSharesNet303
module top #(parameter int K = 1) (input logic [63:0] arr, output logic o);
  case (K)
    1: begin : g
      wire [3:0] w = arr[7:4];
      wire x = arr[3] | arr[2];
    end
    default: begin : h
      wire [3:0] w = arr[3:0];
    end
  endcase
  assign o = arr[0];
endmodule
