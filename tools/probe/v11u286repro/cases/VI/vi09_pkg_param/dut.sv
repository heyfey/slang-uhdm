// § foldIntTsSignedKwTrim286
package pk;
  parameter int signed P = 3;
endpackage
module top;
  logic [7:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = pk::P + i;
  end
endmodule
