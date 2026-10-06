// § genCaPsBoundOpChain254 (bounds over a localparam, an imported parameter, a package-qualified parameter and a macro-born parameter)
`define MW 4
package gp; parameter int GW = 4; endpackage
module top import gp::*; #(parameter int W = 4) (input logic [15:0] a, output logic [3:0] o [4]);
  localparam int L = 4;
  for (genvar k = 0; k < 1; k++) begin : g
    assign o[0] = a[L+3:L];
    assign o[1] = a[GW*2-1:GW];
    assign o[2] = a[gp::GW+3:gp::GW];
    assign o[3] = a[`MW*3-1:`MW*2];
  end
endmodule
