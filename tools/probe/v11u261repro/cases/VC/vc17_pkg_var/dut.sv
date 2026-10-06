// § qselPkgParamOnly261v
package cp;
  logic [3:0][7:0] VR;
  localparam logic [3:0][7:0] LR = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top (input logic [3:0] a, output logic [3:0] o [2], output logic [3:0] q [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = a ^ cp::VR[k][3:0];
    assign q[k] = a ^ cp::LR[k][3:0];
  end
endmodule
