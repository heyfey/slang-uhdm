// § pkgQualRefShadowOwnTs264
package pk;
  parameter logic [7:0] NE = 8'd12;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  localparam logic [7:0] NE = pk::NE;
  assign o = NE;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
