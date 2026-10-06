// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  assign o = '0;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
