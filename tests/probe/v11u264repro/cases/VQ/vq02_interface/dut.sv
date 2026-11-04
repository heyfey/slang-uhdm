// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
endpackage
interface ifc;
  import pk::*;
  localparam int NE = pk::NE;
  logic [NE-1:0] d;
endinterface
module top(output logic [11:0] o);
  ifc i();
  assign o = i.d;
endmodule
