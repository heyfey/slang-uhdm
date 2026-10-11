// § foldIntTsSignedKwTrim286
module top #(parameter int signed P = 3);
  logic [63:0] o;
  if (P > 0) begin : g
    assign o = P;
  end
endmodule
