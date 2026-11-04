// § foldIntTsSignedKwTrim286
module top #(parameter int signed P = 2, int signed Q = 3);
  logic [63:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = Q;
  end
endmodule
