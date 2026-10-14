// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0] mu [2], input logic [1:0] s, output logic o);
  child c (.d(mu[s][1]), .q(o));
endmodule
