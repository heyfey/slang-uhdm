// § genCaCastFoldOrphanName282
module top #(parameter int W = 4, parameter int P = 3) (output logic [3:0] z);
  if (1) begin : gi
    assign z = W'(P);
  end
endmodule
