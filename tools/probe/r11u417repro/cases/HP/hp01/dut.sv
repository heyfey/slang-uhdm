// § hierSelParenBoundPretty417
module top #(parameter int W = 64) (output logic [W-1:0] o);
  typedef struct packed { logic [W-1:0] data; } pkt_s;
  pkt_s s;
  for (genvar i = 0; i < 3; i++) begin : g
    logic [W-1:0] t;
    assign t = {(W/(8*(2**i))){s.data[0+:(8*(2**i))]}};
  end
  assign o = g[0].t;
endmodule
