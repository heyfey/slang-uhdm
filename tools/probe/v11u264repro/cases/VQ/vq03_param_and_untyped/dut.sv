// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
  parameter logic [3:0] NU = 4'd5;
  parameter NV = 7;
endpackage
module sub(output logic [15:0] o);
  import pk::*;
  parameter int NE = pk::NE;
  localparam NU = pk::NU;
  localparam int NV = pk::NV;
  assign o = NE + NU + NV;
endmodule
module top(output logic [15:0] o);
  sub u(.o(o));
endmodule
