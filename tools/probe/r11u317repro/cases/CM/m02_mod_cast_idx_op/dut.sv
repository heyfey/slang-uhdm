// § modConnIdxNestedNames317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, input logic [1:0] k, input logic [1:0][1:0] m, input logic a, output logic o);
  child c (.d(ck[2'(s)] & ck[0]), .q(o));
endmodule
