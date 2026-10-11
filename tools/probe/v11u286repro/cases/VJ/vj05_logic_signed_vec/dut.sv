// § foldIntTsSignedKwTrim286
module top #(parameter logic signed [3:0] P = 4'sd3);
  logic [63:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = P;
  end
endmodule
