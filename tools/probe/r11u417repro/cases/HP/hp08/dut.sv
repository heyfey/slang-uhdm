// § hierSelParenBoundPretty417
module top #(parameter int W = 64) (output logic [W-1:0] o);
  typedef struct packed { logic [W-1:0] data; } pkt_s;
  pkt_s s;
  for (genvar i = 0; i < 3; i++) begin : g
    logic [7:0] t;
    assign t = s.data[(i*8)+:8];
  end
  assign o = g[0].t;
endmodule
