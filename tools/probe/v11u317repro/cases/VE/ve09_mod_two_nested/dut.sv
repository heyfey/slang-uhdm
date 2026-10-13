// § modConnIdxNestedNames317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [1:0] k, output logic o);
  child c (.d(ck[k[0]] & ck[k[1]]), .q(o));
endmodule
