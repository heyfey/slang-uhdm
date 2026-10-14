// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    child c (.d(m[i][s]), .q());
  end
  assign o = a;
endmodule
