// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
endpackage
module sub import pk::*; (output logic [7:0] o);
  localparam int NE = pk::NE;
  assign o = NE;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
