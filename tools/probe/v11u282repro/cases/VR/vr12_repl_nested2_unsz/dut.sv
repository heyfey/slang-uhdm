// § genCaReplCountUnsizedClone282
module top #(parameter int W = 2) (input logic [7:0] e, output logic [7:0] q [2][2]);
  for (genvar x = 0; x < 2; x++) begin : gx
    for (genvar y = 0; y < 2; y++) begin : gy
      assign q[x][y] = {W{e[3:0]}} | '0;
    end
  end
endmodule
