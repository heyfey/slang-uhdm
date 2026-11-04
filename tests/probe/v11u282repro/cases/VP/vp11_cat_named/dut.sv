// § genProcCatFoldInst282
module top #(parameter int P = 4) (output logic [7:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb begin : nb
      z[w] = {P[3:0], 4'b0};
    end
  end
endmodule
