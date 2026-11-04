// § foldIntTsSignedKwTrim286
module top #(parameter int signed P = 1);
  logic [7:0] o [2];
  logic [7:0] w;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = w[P+:2];
  end
endmodule
