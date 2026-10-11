// § genProcCatFoldInst282
module top #(parameter int P = 4) (output logic [3:0] z [2], output logic [3:0] y [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb {z[w], y[w]} = {P[3:0], 4'(P + 1)};
  end
endmodule
