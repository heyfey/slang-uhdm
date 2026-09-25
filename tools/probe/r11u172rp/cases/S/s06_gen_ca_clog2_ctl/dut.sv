module top #(parameter int W = 8, parameter int C = 0) (input logic [W-1:0] a, output logic [31:0] y);
  generate
  if (C == 1) begin: g1
    assign y = 0;
  end else begin: g0
    assign y = $clog2(W) + a;
  end
  endgenerate
endmodule
