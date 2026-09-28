// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = 3;
  class C;
    localparam int unsigned W = 5;
  endclass
endpackage
class K;
  localparam int unsigned V = 6;
endclass
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  assign y1 = x[p::C::W:0];
  assign y2 = x[K::V:p::S];
  assign y3 = x[p::S:0];
endmodule
