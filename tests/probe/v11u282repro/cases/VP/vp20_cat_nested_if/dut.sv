// § genProcCatFoldInst282
module top #(parameter int P = 4) (output logic [7:0] z [2][2]);
  for (genvar x = 0; x < 2; x++) begin : gx
    if (x < 2) begin : gi
      always_comb z[x][0] = {P{1'b1}};
      always_comb z[x][1] = ~P;
    end
  end
endmodule
