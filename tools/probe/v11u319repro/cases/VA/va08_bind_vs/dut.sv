// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module tgt (input logic [1:0][1:0] m, input logic [1:0] s, output logic o);
  assign o = m[0][0];
endmodule
bind tgt child cb (.d(m[s][1]), .q());
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  tgt t0 (.m(m), .s(s), .o(o));
endmodule
