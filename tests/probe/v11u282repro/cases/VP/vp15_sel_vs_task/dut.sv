// § genProcFoldTsInstFromSelect282
module top #(parameter int FW = 2) (input logic [7:0] cl [2], input logic [1:0] off [2], output logic [1:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb begin : nb
      z[i] = cl[i][{off[i], 1'b0} +: FW];
    end
  end
endmodule
