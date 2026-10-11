// § foldIntTsSignedKwTrim286
interface ifc #(parameter int signed P = 3);
  logic [7:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = P + i;
  end
endinterface
module top;
  ifc i();
endmodule
