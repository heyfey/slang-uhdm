// § genLoopDirectBoundPaCopy280
// a case-generate inside a for-generate, the bound on the left side select
module top (input logic [1:0] a, output logic [31:0] sig [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    case (i)
      0: begin : c0 assign sig[i][R4 +: 2] = a; end
      default: begin : cd assign sig[i][R4 +: 2] = ~a; end
    endcase
  end
endmodule
