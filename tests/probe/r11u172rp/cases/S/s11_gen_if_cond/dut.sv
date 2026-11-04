module top #(parameter int W = 8, parameter int C = 0) (input logic [W-1:0] a, output logic [W-1:0] y);
  generate
  if ($signed(C) > 0) begin: g1
    assign y = a;
  end else begin: g0
    assign y = ~a;
  end
  endgenerate
endmodule
