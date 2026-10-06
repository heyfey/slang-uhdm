// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
endpackage
module sub import pk::*; (output logic [7:0] o);
  localparam int W = pk::NE;
  assign o = W;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
