// § foldIntTsSignedKwTrim286
module top #(parameter int signed P = 2);
  logic [7:0] o [4];
  for (genvar i = 0; i < P; i++) begin : g
    assign o[i] = P;
  end
endmodule
