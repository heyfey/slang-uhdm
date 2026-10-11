// § foldIntTsSignedKwTrim286
module top;
  localparam int signed L = 2;
  logic [7:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = L + i;
  end
endmodule
