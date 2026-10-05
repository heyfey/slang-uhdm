// § pcwRefLastWriter250
// an importing module shadows the package's W with its own localparam W, both used as paren-cast widths
package p;
  parameter int W = 8;
  localparam logic [15:0] X = (W)'(16'h1ff);
endpackage
module top(output logic [15:0] y, output logic [7:0] o);
  import p::*;
  localparam int W = 3;
  localparam logic [7:0] Z = (W)'(8'hff);
  assign y = X;
  assign o = Z;
endmodule
