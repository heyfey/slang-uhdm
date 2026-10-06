// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
endpackage
module sub(input logic [31:0] i, output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  localparam int N2 = pk::NE + 1;
  logic [NE-1:0] r;
  assign r = i[NE-1:0];
  assign o = r[3:0] + N2 + i[NE +: 2];
endmodule
module top(input logic [31:0] i, output logic [7:0] o);
  sub u(.i(i), .o(o));
endmodule
