// § psBoundPaOwnerName192 § caPsSelFullVerbatim192
package p;
  parameter int unsigned W = 3;
endpackage
module chk (input logic [3:0] a, output logic ok);
  assign ok = |a;
endmodule
module sub import p::*; (input logic [31:0] x, output logic [31:0] y, output logic ok);
  assign y = x[W:0];
endmodule
module top (input logic [31:0] x, output logic [31:0] y, output logic ok);
  sub u (.*);
endmodule
bind sub chk u_chk (.a(x[p::W:0]), .ok(ok));
