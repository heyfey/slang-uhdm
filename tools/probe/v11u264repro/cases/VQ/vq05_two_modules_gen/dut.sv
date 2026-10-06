// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 2;
endpackage
module a(output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  for (genvar k = 0; k < NE; k++) begin : g
    assign o[k] = 1'b1;
  end
  assign o[7:NE] = '0;
endmodule
module b import pk::*; (output logic [7:0] o);
  localparam int NE = pk::NE;
  assign o = NE;
endmodule
module top(output logic [7:0] o, output logic [7:0] p);
  a ua(.o(o));
  b ub(.o(p));
endmodule
