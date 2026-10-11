// § foldIntTsSignedKwTrim286
module top #(parameter bit signed [7:0] P = 3);
  logic [7:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = P + i;
  end
endmodule
