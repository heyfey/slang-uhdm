// § genLoopDirectBoundPaConst262 (for-generate, direct bound in a nested for and a case-generate inside the loop)
module m #(parameter int Width = 32, parameter int K = 0) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    case (K)
      0: begin : gc
        assign q[i*3+:3] = a[i+:Width];
      end
    endcase
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
