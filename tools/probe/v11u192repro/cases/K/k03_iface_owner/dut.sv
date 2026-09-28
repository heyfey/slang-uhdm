// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
interface bus_if import p::*; (input logic [31:0] x);
  logic [31:0] y, z;
  assign y = x[W:0];
  always_comb z = x[31:W];
endinterface
module top (input logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
  bus_if b (.x(x));
  assign y = b.y;
  assign z = b.z;
endmodule
