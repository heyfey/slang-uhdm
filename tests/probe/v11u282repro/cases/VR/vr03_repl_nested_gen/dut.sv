// § genCaReplCountInst282
module top #(parameter int W = 2) (input logic [7:0] e, output logic [3:0] q [2][2]);
  for (genvar x = 0; x < 2; x++) begin : gx
    if (x == 0) begin : gi
      for (genvar y = 0; y < 2; y++) begin : gy
        assign q[x][y] = {W{e[1:0]}};
      end
    end else begin : ge
      assign q[x][0] = '0; assign q[x][1] = '0;
    end
  end
endmodule
