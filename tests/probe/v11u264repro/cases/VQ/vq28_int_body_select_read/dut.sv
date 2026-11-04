// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 3;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  assign o[0] = i[NE];
  assign o[5:1] = i[NE +: 5];
  assign o[7:6] = {2{i[NE]}};
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub u(.i(i), .o(o));
endmodule
