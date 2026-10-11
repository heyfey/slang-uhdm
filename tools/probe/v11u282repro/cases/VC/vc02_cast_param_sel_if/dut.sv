// § genCaCastFoldOrphanName282
module top #(parameter int W = 4, parameter int P = 3) (output logic [3:0] z);
  if (1) begin : gi
    logic [3:0] q;
    assign q = W'(P);
    assign z = q;
  end
endmodule
module wrap(output logic [3:0] z); top #(.P(5)) u(.z(z)); endmodule
