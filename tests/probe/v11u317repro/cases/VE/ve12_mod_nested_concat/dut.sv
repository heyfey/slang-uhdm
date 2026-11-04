// § modConnIdxNestedNames317
module child2 (input logic [1:0] d, output logic q);
  assign q = d[0];
endmodule
module top (input logic [3:0] ck, input logic [1:0] k, input logic a, output logic o);
  child2 c (.d({ck[k[0]], a}), .q(o));
endmodule
