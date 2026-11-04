// § genCaLhsIpsBoundInPlace282
module top #(parameter int P = 5) (output logic [7:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [7:0] v;
    assign v[P -: 4] = 4'hA;
    assign v[7:6] = '0; assign v[1:0] = '0;
    assign o[g] = v;
  end
endmodule
