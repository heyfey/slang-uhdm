// § ndaRangeQueryFold216 — $high in a net initializer inside a generate block
module dut (input logic [5:2] i, output logic [3:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    wire [3:0] w = $high(i);
  end
  assign o = g[0].w;
endmodule
