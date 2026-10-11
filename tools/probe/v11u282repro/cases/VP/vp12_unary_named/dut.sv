// § genProcUnaryFoldInst282
module top #(parameter int P = 4) (input logic [7:0] a [2], output logic [7:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb begin : nb
      z[w] = a[w] & ~P;
    end
  end
endmodule
