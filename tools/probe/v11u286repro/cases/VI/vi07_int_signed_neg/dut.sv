// § foldIntTsSignedKwTrim286
module top #(parameter int signed P = -2);
  logic [7:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = P + i;
  end
endmodule
