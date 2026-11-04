// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
  typedef struct packed { logic [31:0] f; logic [31:0] g; } s_t;
endpackage
module top import p::*; (input s_t s, output logic [31:0] y, output logic [31:0] z);
  assign y = s.f[W:0];
  for (genvar i = 0; i < 1; i++) begin : g
    assign z = s.g[31:W];
  end
endmodule
