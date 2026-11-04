// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module mid (input logic [1:0][1:0] mm, input logic [1:0] ss, output logic q);
  child c (.d(mm[ss][1]), .q(q));
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  mid u (.mm(m), .ss(s), .q(o));
endmodule
