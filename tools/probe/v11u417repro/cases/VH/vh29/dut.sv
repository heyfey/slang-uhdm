// § hierSelParenBoundPretty417

module top #(parameter int N = 8, parameter int W = 16) (input logic [3:0] i, output logic [63:0] o);
  typedef struct packed { logic [63:0] data; } pkt_s;
  pkt_s s;
  assign o = 64'(s.data[(N):(N-2)]);
endmodule
