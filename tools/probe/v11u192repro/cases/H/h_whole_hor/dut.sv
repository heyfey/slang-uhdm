// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
  typedef struct packed { logic [31:0] f; logic [31:0] g; } s_t;
endpackage
module top import p::*; (input s_t s, output logic [31:0] z, output s_t t, output logic [31:0] z2 [1]);
  for (genvar i = 0; i < 1; i++) begin : g
    assign z = s.g[31:W] | 32'd0;
  end
endmodule
