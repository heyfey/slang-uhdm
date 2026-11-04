module top #(parameter int W = 8, parameter int C = 0) (input logic [W-1:0] a, output logic [W-1:0] y);
  generate
  if (C == 1) begin: g1
    assign y = a;
  end else begin: g0
    assign y = $unsigned(a[W-1:1]) + $signed({1'b0, a[0]});
  end
  endgenerate
endmodule
