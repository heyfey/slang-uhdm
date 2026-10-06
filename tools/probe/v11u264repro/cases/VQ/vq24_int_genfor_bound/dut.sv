// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 3;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  for (genvar i = 0; i < NE; i++) begin : g
    assign o[i] = 1'b1;
  end
  assign o[7:3] = '0;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
