// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
  typedef struct packed { logic [31:0] f; logic [31:0] g; } s_t;
endpackage
module top import p::*; (input logic [31:0] x, input logic c, output logic [31:0] z, output s_t s, output logic [15:0] a, output logic [15:0] b);
  for (genvar i = 0; i < 1; i++) begin : g
    assign {a, b} = 32'(x[W:0]);
  end
endmodule
