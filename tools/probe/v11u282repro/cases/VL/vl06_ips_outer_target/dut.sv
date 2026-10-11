// § genCaLhsIpsBoundInPlace282
module top #(parameter int P = 2) (output logic [7:0] v);
  for (genvar g = 0; g < 1; g++) begin : gb
    assign v[P +: 4] = 4'hA;
  end
  assign v[7:6] = '0; assign v[1:0] = '0;
endmodule
