// § modConnIdxNestedNames317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [2:0] k, input logic s, input logic a, output logic o);
  child c (.d(ck[k[s+1]] & a), .q(o));
endmodule
