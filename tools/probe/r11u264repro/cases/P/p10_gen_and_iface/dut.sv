// § elabParamRefSignedTsUnlocated264
interface ifc #(parameter int W = 3);
  localparam int WW = W;
  logic [WW-1:0] d;
endinterface
module top #(parameter int P = 2) (output logic [7:0] o);
  ifc i();
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam int GL = P;
    assign o[g] = GL[0];
  end
  if (P == 2) begin : gi
    localparam int GI = P;
    assign o[7] = GI[1];
  end
  localparam int BW = P;
  assign o[6:2] = BW;
endmodule
