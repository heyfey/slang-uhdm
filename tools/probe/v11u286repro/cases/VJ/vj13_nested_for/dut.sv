// § foldIntTsSignedKwTrim286
module top #(parameter int signed P = 1);
  logic [63:0] o [2][2];
  for (genvar i = 0; i < 2; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      assign o[i][j] = P;
    end
  end
endmodule
