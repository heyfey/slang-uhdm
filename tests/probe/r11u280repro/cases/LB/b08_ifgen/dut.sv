// § genLoopDirectBoundPaCopy280
// an if-generate and a case-generate scope
module top #(parameter int M = 1) (input logic [31:0] sig, output logic [63:0] z);
  localparam logic [3:0] R4 = {2{2'b01}};
  if (M == 1) begin : gi
    logic [1:0] y;
    assign y = sig[R4 +: 2];
  end
  case (M)
    1: begin : gc
      logic [1:0] y;
      assign y = sig[R4 +: 2];
    end
    default: begin : gd
    end
  endcase
  assign z = 64'b0;
endmodule
