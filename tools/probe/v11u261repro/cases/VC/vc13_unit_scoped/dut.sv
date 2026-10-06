// § qselPkgParamOnly261v
parameter logic [3:0][7:0] URC = {8'h11, 8'h22, 8'h33, 8'h44};
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = a ^ $unit::URC[k][W-1:0];
  end
endmodule
