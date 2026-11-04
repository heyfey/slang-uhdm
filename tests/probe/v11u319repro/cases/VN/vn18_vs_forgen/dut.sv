// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    logic q;
    child c (.d(m[s][i]), .q(q));
  end
  assign o = g[0].q;
endmodule
