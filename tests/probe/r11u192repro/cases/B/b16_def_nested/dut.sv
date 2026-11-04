// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, input logic c,
  output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4,
  output logic [31:0] y5, output logic [31:0] y6, output logic [31:0] y7, output logic [31:0] y8);
  typedef struct packed { logic [15:0] f; logic [15:0] g; } s_t;
  s_t sv;
  assign sv = x;
  function automatic logic [31:0] f(input logic [31:0] a);
    return a;
  endfunction
  assign y1 = f(x[S:0]);
  assign y2 = $unsigned(x[S:0]);
  assign y3 = c ? x[S:0] : x[31:S];
  assign y4 = 32'(x[S:0]);
  assign y5 = sv.f[S:0];
  assign y6 = {<<{x[S:0]}};
  assign y7 = x[S:0] == 5'd3;
  assign y8 = ~x[S:0];
endmodule
