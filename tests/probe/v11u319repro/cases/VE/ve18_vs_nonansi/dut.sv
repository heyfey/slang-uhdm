// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (m, s, t, o);
  input logic [1:0][1:0] m;
  input logic [1:0] s, t;
  output logic o;
  child c (.d(m[s][t]), .q(o));
endmodule
