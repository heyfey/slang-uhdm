// § genCaLhsIpsBoundInPlace282
module top #(parameter int P = 2) (output logic [7:0] o [2][2]);
  for (genvar x = 0; x < 2; x++) begin : gx
    if (x >= 0) begin : gi
      for (genvar y = 0; y < 2; y++) begin : gy
        logic [7:0] v;
        assign v[P +: 4] = 4'hA;
        assign v[7:6] = '0; assign v[1:0] = '0;
        assign o[x][y] = v;
      end
    end
  end
endmodule
