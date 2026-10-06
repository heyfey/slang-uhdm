// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
  parameter int NG = 2;
endpackage
module sub(output logic [7:0] o);
  import pk::NG;
  localparam int W = pk::NE;
  localparam int V = pk::NG;
  assign o = W + V;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
