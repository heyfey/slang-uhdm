// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
  parameter int NF = 3;
endpackage
module sub import pk::*; (output logic [7:0] o);
  localparam int NE = pk::NE;
  localparam int Y = NF;
  localparam int Z = NE;
  assign o = NE + Y + Z;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
