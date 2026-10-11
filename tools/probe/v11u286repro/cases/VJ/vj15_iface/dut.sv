// § foldIntTsSignedKwTrim286
interface ifc #(parameter int signed P = 3);
  logic [63:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = P;
  end
endinterface
module top;
  ifc i();
endmodule
