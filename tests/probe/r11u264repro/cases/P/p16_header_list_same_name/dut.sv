// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
endpackage
module sub import pk::*; #(parameter int Q = 1) (output logic [7:0] o);
  localparam int NE = pk::NE;
  assign o = NE + Q;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
