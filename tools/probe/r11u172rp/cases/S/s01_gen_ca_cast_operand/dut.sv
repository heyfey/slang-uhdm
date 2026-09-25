module top #(parameter int W = 8, parameter int C = 0) (input logic [W-1:0] a, input logic [2:0] s, output logic [W-1:0] y);
  generate
  if (C == 1) begin: g1
    assign y = a;
  end else begin: g0
    assign y = W'($signed(a) >>> s);
  end
  endgenerate
endmodule
